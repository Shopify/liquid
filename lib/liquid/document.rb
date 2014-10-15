module Liquid
  class Document < BlockBody
    def self.parse(tokens, options)
      doc = new
      doc.parse(tokens, options)
      doc
    end

    def parse(tokens, options)
      super do |end_tag_name, end_tag_params|
        unknown_tag(end_tag_name, options) if end_tag_name
      end
    end

    def unknown_tag(tag, options)
      case tag
      when 'else'.freeze, 'end'.freeze
        raise SyntaxError.new(options[:locale].t("errors.syntax.unexpected_outer_tag".freeze, :tag => tag))
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.unknown_tag".freeze, :tag => tag))
      end
    end
  end
end
