module Liquid
  class Block < Tag
    IsTag             = /\A#{TagStart}/o
    IsVariable        = /\A#{VariableStart}/o
    FullToken         = /\A#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/om
    ContentOfVariable = /\A#{VariableStart}(.*)#{VariableEnd}\z/om

    def blank?
      @blank || false
    end

    def parse(tokens)
      @blank = true
      @nodelist ||= []
      @nodelist.clear

      # All child tags of the current block.
      @children = []

      while token = tokens.shift
        case token
        when IsTag
          if token =~ FullToken

            # if we found the proper block delimiter just end parsing here and let the outer block
            # proceed
            if block_delimiter == $1
              end_tag
              return
            end

            # fetch the tag from registered blocks
            if tag = Template.tags[$1]
              new_tag = tag.parse($1, $2, tokens, @options)
              @blank &&= new_tag.blank?
              @nodelist << new_tag
              @children << new_tag
            else
              # this tag is not registered with the system
              # pass it to the current block for special handling or error reporting
              unknown_tag($1, $2, tokens)
            end
          else
            raise SyntaxError.new(options[:locale].t("errors.syntax.tag_termination", :token => token, :tag_end => TagEnd.inspect))
          end
        when IsVariable
          new_var = create_variable(token)
          @nodelist << new_var
          @children << new_var
          @blank = false
        when ''
          # pass
        else
          @nodelist << token
          @blank &&= (token =~ /\A\s*\z/)
        end
      end

      # Make sure that it's ok to end parsing in the current block.
      # Effectively this method will throw an exception unless the current block is
      # of type Document
      assert_missing_delimitation!
    end

    # warnings of this block and all sub-tags
    def warnings
      all_warnings = []
      all_warnings.concat(@warnings) if @warnings

      (@children || []).each do |node|
        all_warnings.concat(node.warnings || [])
      end

      all_warnings
    end

    def end_tag
    end

    def unknown_tag(tag, params, tokens)
      case tag
      when 'else'
        raise SyntaxError.new(options[:locale].t("errors.syntax.unexpected_else", 
                                                 :block_name => block_name))
      when 'end'
        raise SyntaxError.new(options[:locale].t("errors.syntax.invalid_delimiter", 
                                                 :block_name => block_name, 
                                                 :block_delimiter => block_delimiter))
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.unknown_tag", :tag => tag))
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
      raise SyntaxError.new(options[:locale].t("errors.syntax.variable_termination", :token => token, :tag_end => VariableEnd.inspect))
    end

    def render(context)
      render_all(@nodelist, context)
    end

    protected

    def assert_missing_delimitation!
      raise SyntaxError.new(options[:locale].t("errors.syntax.tag_never_closed", :block_name => block_name))
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
            raise MemoryError.new("Memory limits exceeded")
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
