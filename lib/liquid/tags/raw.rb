module Liquid
  class Raw < Block
    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear

      while token = tokens.shift
        if token =~ FullToken
          if block_delimiter == $1
            end_tag
            return
          end
        end
        @nodelist << token if not token.empty?
      end
    end

    def render(context)
      if context.intermediate
        @nodelist.unshift("{%raw%}")
        @nodelist << "{%endraw%}"
      end
      super
    end

  end

  Template.register_tag('raw', Raw)
end

