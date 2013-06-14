module Liquid
  class Raw < Block
    FullTokenPossiblyInvalid = /^(.*)#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}$/o

    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear
      while token = tokens.shift
        if token =~ FullTokenPossiblyInvalid
          @nodelist << $1 if $1 != ""
          if block_delimiter == $2
            end_tag
            return
          end
        end
        @nodelist << token if not token.empty?
      end
    end
  end

  Template.register_tag('raw', Raw)
end
