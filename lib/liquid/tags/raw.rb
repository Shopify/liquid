module Liquid
  class Raw < Block
    Syntax = /\A\s*\z/
    FullTokenPossiblyInvalid = /\A(.*)#{TagStart}\s*(\w+)\s*(.*)?#{TagEnd}\z/om

    def initialize(tag_name, markup, parse_context)
      super

      ensure_valid_markup(tag_name, markup, parse_context)
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

      raise SyntaxError.new(parse_context.locale.t("errors.syntax.tag_never_closed".freeze, block_name: block_name))
    end

    def render_to_output_buffer(_context, output)
      output << @body
      output
    end

    def nodelist
      [@body]
    end

    def blank?
      @body.empty?
    end

    def format(left, right)
      output = "{%#{"-" if left} raw #{"-" if right}%}"
      output << super
      output << "{%#{"-" if left} endraw #{"-" if right}%}"
    end

    protected

    def ensure_valid_markup(tag_name, markup, parse_context)
      unless markup =~ Syntax
        raise SyntaxError.new(parse_context.locale.t("errors.syntax.tag_unexpected_args".freeze, tag: tag_name))
      end
    end
  end

  Template.register_tag('raw'.freeze, Raw)
end
