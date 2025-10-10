# frozen_string_literal: true

require 'liquid/tag/disabler'
require 'liquid/tag/disableable'

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

      def disable_tags(*tag_names)
        tag_names += disabled_tags
        define_singleton_method(:disabled_tags) { tag_names }
        prepend(Disabler)
      end

      private :new

      protected

      def disabled_tags
        []
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

    # For backwards compatibility with custom tags. In a future release, the semantics
    # of the `render_to_output_buffer` method will become the default and the `render`
    # method will be removed.
    def render_to_output_buffer(context, output)
      render_result = render(context)
      output << render_result if render_result
      output
    end

    def blank?
      false
    end

    private

    def parse_expression(markup)
      parse_context.parse_expression(markup)
    end
  end
end
