module Liquid
  class Raw < Block
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/om

    def parse(tokens)
      @nodelist ||= []
      @nodelist.clear
      while token = tokens.shift
        if token =~ FullTokenPossiblyInvalid
          @nodelist << $1 if $1 != "".freeze
          return if block_delimiter == $2
        end
        @nodelist << token if not token.empty?
      end
    end
  end

  Template.register_tag('raw'.freeze, Raw)
end
