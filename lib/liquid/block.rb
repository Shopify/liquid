module Liquid

  class Block < Tag
    IsTag             = /^#{TagStart}/o
    IsVariable        = /^#{VariableStart}/o
    FullToken         = /^#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}$/o
    ContentOfVariable = /^#{VariableStart}(.*)#{VariableEnd}$/o

    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear

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
              @nodelist << tag.new($1, $2, tokens)
            else
              # this tag is not registered with the system
              # pass it to the current block for special handling or error reporting
              unknown_tag($1, $2, tokens)
            end
          else
            raise SyntaxError, "Tag '#{token}' was not properly terminated with regexp: #{TagEnd.inspect} "
          end
        when IsVariable
          @nodelist << create_variable(token)
        when ''
          # pass
        else
          @nodelist << token
        end
      end

      # Make sure that it's ok to end parsing in the current block.
      # Effectively this method will throw an exception unless the current block is
      # of type Document
      assert_missing_delimitation!
    end

    def end_tag
    end

    def unknown_tag(tag, params, tokens)
      case tag
      when 'else'
        raise SyntaxError, "#{block_name} tag does not expect else tag"
      when 'end'
        raise SyntaxError, "'end' is not a valid delimiter for #{block_name} tags. use #{block_delimiter}"
      else
        raise SyntaxError, "Unknown tag '#{tag}'"
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
        return Variable.new(content.first)
      end
      raise SyntaxError.new("Variable '#{token}' was not properly terminated with regexp: #{VariableEnd.inspect} ")
    end

    def render(context)
      render_all(@nodelist, context)
    end

    protected

    def assert_missing_delimitation!
      raise SyntaxError.new("#{block_name} tag was never closed")
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
          context.resource_limits[:render_length_current] += (token_output.respond_to?(:length) ? token_output.length : 1)
          if context.resource_limits_reached?
            context.resource_limits[:reached] = true
            raise MemoryError.new("Memory limits exceeded")
          end
          output << token_output
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
