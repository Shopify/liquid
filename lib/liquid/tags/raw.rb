module Liquid
  class Raw < Block
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/om

    def parse(tokens)
      @body = ''
      while token = tokens.shift
        if token =~ FullTokenPossiblyInvalid
          @body << $1 if $1 != "".freeze
          return if block_delimiter == $2
        end
        @body << token if not token.empty?
      end
    end

    def render(context)
      @body
    end

    def nodelist
      [@body]
    end

    def blank?
      @body.empty?
    end
  end

  Template.register_tag('raw'.freeze, Raw)
end
