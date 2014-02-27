module Liquid
  class Raw < Block
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/o

    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear
      while token = tokens.shift
        if token =~ FullTokenPossiblyInvalid
          @nodelist << $1 if $1 != ""
          return if block_delimiter == $2
        end
        @nodelist << token if not token.empty?
      end
    end
  end

  Template.register_tag('raw', Raw)
end
