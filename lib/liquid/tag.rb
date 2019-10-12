# frozen_string_literal: true

module Liquid
  class Tag
    attr_reader :nodelist, :tag_name, :line_number, :parse_context
    alias_method :options, :parse_context
    include ParserSwitching

    class << self
      def parse(tag_name, markup, tokenizer, parse_context)
        tag = new(tag_name, markup, parse_context)
        tag.parse(tokenizer)
        tag
      end

      def disable_tags(*tags)
        disabled_tags.push(*tags)
      end

      private :new

      def disabled_tags
        @disabled_tags ||= []
      end
    end

    def initialize(tag_name, markup, parse_context)
      @tag_name      = tag_name
      @markup        = markup
      @parse_context = parse_context
      @line_number   = parse_context.line_number
    end

    def parse(_tokens)
    end

    def raw
      "#{@tag_name} #{@markup}"
    end

    def name
      self.class.name.downcase
    end

    def render(_context)
      ''
    end

    def disabled?(context)
      context.registers[:disabled_tags].disabled?(tag_name)
    end

    def disabled_error_message
      "#{tag_name} #{options[:locale].t('errors.disabled.tag')}"
    end

    # For backwards compatibility with custom tags. In a future release, the semantics
    # of the `render_to_output_buffer` method will become the default and the `render`
    # method will be removed.
    def render_to_output_buffer(context, output)
      output << render(context)
      output
    end

    def blank?
      false
    end

    def disabled_tags
      self.class.disabled_tags
    end
  end
end
