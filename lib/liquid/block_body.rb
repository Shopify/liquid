module Liquid
  class BlockBody
    FullToken = /\A#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/om
    ContentOfVariable = /\A#{VariableStart}(.*)#{VariableEnd}\z/om
    TAGSTART = "{%".freeze
    VARSTART = "{{".freeze

    attr_reader :nodelist

    def initialize
      @nodelist = []
      @blank = true
    end

    def parse(tokens, options)
      while token = tokens.shift
        begin
          unless token.empty?
            case
            when token.start_with?(TAGSTART)
              if token =~ FullToken
                tag_name = $1
                markup = $2
                # fetch the tag from registered blocks
                if tag = Template.tags[tag_name]
                  markup = token.child(markup) if token.is_a?(Token)
                  new_tag = tag.parse(tag_name, markup, tokens, options)
                  new_tag.line_number = token.line_number if token.is_a?(Token)
                  @blank &&= new_tag.blank?
                  @nodelist << new_tag
                else
                  # end parsing if we reach an unknown tag and let the caller decide
                  # determine how to proceed
                  return yield tag_name, markup
                end
              else
                raise SyntaxError.new(options[:locale].t("errors.syntax.tag_termination".freeze, :token => token, :tag_end => TagEnd.inspect))
              end
            when token.start_with?(VARSTART)
              new_var = create_variable(token, options)
              new_var.line_number = token.line_number if token.is_a?(Token)
              @nodelist << new_var
              @blank = false
            else
              @nodelist << token
              @blank &&= !!(token =~ /\A\s*\z/)
            end
          end
        rescue SyntaxError => e
          e.set_line_number_from_token(token)
          raise
        end
      end

      yield nil, nil
    end

    def blank?
      @blank
    end

    def warnings
      all_warnings = []
      nodelist.each do |node|
        all_warnings.concat(node.warnings) if node.respond_to?(:warnings) && node.warnings
      end
      all_warnings
    end

    def render(context)
      output = []
      context.resource_limits[:render_length_current] = 0
      context.resource_limits[:render_score_current] += @nodelist.length

      @nodelist.each do |token|
        # Break out if we have any unhanded interrupts.
        break if context.has_interrupt?

        begin
          # If we get an Interrupt that means the block must stop processing. An
          # Interrupt is any command that stops block execution such as {% break %}
          # or {% continue %}
          if token.is_a?(Continue) or token.is_a?(Break)
            context.push_interrupt(token.interrupt)
            break
          end

          token_output = render_token(token, context)

          unless token.is_a?(Block) && token.blank?
            output << token_output
          end
        rescue MemoryError => e
          raise e
        rescue ::StandardError => e
          output << context.handle_error(e, token)
        end
      end

      output.join
    end

    private

    def render_token(token, context)
      token_output = (token.respond_to?(:render) ? token.render(context) : token)
      context.increment_used_resources(:render_length_current, token_output)
      if context.resource_limits_reached?
        context.resource_limits[:reached] = true
        raise MemoryError.new("Memory limits exceeded".freeze)
      end
      token_output
    end

    def create_variable(token, options)
      token.scan(ContentOfVariable) do |content|
        markup = token.is_a?(Token) ? token.child(content.first) : content.first
        return Variable.new(markup, options)
      end
      raise SyntaxError.new(options[:locale].t("errors.syntax.variable_termination".freeze, :token => token, :tag_end => VariableEnd.inspect))
    end
  end
end
