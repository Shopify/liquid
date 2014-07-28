module Liquid
  class Document < BlockBody
    def parse(tokens)
      super do |end_tag_name, end_tag_params|
        unknown_tag(end_tag_name) if end_tag_name
      end
    end

    def unknown_tag(tag)
      case tag
      when 'else'.freeze, 'end'.freeze
        raise SyntaxError.new(@options[:locale].t("errors.syntax.unexpected_outer_tag".freeze, :tag => tag))
      else
        raise SyntaxError.new(@options[:locale].t("errors.syntax.unknown_tag".freeze, :tag => tag))
      end
    end
  end
end
