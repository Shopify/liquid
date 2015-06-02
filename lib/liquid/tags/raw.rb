module Liquid
  class Raw < Block
    Syntax = /\A\s*\z/
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/om

    def initialize(tag_name, markup, options)
      super

      unless markup =~ Syntax
        raise SyntaxError.new(@options[:locale].t("errors.syntax.tag_unexpected_args".freeze, tag: tag_name))
      end
    end

    def parse(tokens)
      @body = ''
      while token = tokens.shift
        if token =~ FullTokenPossiblyInvalid
          @body << $1 if $1 != "".freeze
          return if block_delimiter == $2
        end
        @body << token unless token.empty?
      end

      raise SyntaxError.new(@options[:locale].t("errors.syntax.tag_never_closed".freeze, block_name: block_name))
    end

    def render(_context)
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
