module Liquid
  # "While" loops a block until some condition no longer holds true.
  #
  class While < Block
    Syntax = /\A(#{VariableSegment}+)/o

    attr_reader :variable_name

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
      @while_block = BlockBody.new
    end

    def parse(tokens)
      return unless parse_body(@while_block, tokens)
    end

    def nodelist
      @while_block.nodelist
    end

    def render(context)
      result = ''

      context.stack do
        while context[@variable_name] do
          result << @while_block.render(context)

          # Handle any interrupts if they exist.
          if context.interrupt?
            interrupt = context.pop_interrupt
            break if interrupt.is_a? BreakInterrupt
            next if interrupt.is_a? ContinueInterrupt
          end
        end
      end

      result
    end

    protected

    def lax_parse(markup)
      if markup =~ Syntax
        @variable_name = $1
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.while".freeze))
      end
    end

    def strict_parse(markup)
      p = Parser.new(markup)
      @variable_name = p.consume(:id)

      p.consume(:end_of_string)
    end

    private

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        (super).compact
      end
    end
  end

  Template.register_tag('while'.freeze, While)
end
