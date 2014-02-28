module Liquid
  class Block < Tag
    def initialize(tag_name, markup, tokens)
      super
      parse_body(tokens)
    end

    def blank?
      @blank || false
    end

    # warnings of this block and all sub-tags
    def warnings
      all_warnings = []
      all_warnings.concat(@warnings) if @warnings

      (nodelist || []).each do |node|
        all_warnings.concat(node.warnings || []) if node.respond_to?(:warnings)
      end

      all_warnings
    end

    def unknown_tag(tag, params, tokens)
      case tag
      when 'else'.freeze
        raise SyntaxError.new(options[:locale].t("errors.syntax.unexpected_else".freeze,
                                                 :block_name => block_name))
      when 'end'.freeze
        raise SyntaxError.new(options[:locale].t("errors.syntax.invalid_delimiter".freeze,
                                                 :block_name => block_name,
                                                 :block_delimiter => block_delimiter))
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.unknown_tag".freeze, :tag => tag))
      end
    end

    def block_delimiter
      "end#{block_name}"
    end

    def block_name
      @tag_name
    end

    def create_variable(token)
      token.scan(ContentOfVariable) do |content|
        return Variable.new(content.first, @options)
      end
      raise SyntaxError.new(options[:locale].t("errors.syntax.variable_termination".freeze, :token => token, :tag_end => VariableEnd.inspect))
    end

    def render(context)
      render_all(@nodelist, context)
    end

    protected

    def unterminated_variable(token)
      raise SyntaxError.new(options[:locale].t("errors.syntax.variable_termination".freeze, :token => token, :tag_end => VariableEnd.inspect))
    end

    def unterminated_tag(token)
      raise SyntaxError.new(options[:locale].t("errors.syntax.tag_termination".freeze, :token => token, :tag_end => TagEnd.inspect))
    end

    def assert_missing_delimitation!
      raise SyntaxError.new(options[:locale].t("errors.syntax.tag_never_closed".freeze, :block_name => block_name))
    end

    def render_all(list, context)
      output = []
      context.resource_limits[:render_length_current] = 0
      context.resource_limits[:render_score_current] += list.length

      list.each do |token|
        # Break out if we have any unhanded interrupts.
        break if context.has_interrupt?

        begin
          # If we get an Interrupt that means the block must stop processing. An
          # Interrupt is any command that stops block execution such as {% break %}
          # or {% continue %}
          if token.is_a? Continue or token.is_a? Break
            context.push_interrupt(token.interrupt)
            break
          end

          token_output = (token.respond_to?(:render) ? token.render(context) : token)
          context.increment_used_resources(:render_length_current, token_output)
          if context.resource_limits_reached?
            context.resource_limits[:reached] = true
            raise MemoryError.new("Memory limits exceeded".freeze)
          end
          unless token.is_a?(Block) && token.blank?
            output << token_output
          end
        rescue MemoryError => e
          raise e
        rescue ::StandardError => e
          output << (context.handle_error(e))
        end
      end

      output.join
    end
  end
end
