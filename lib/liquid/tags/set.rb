# frozen_string_literal: true

module Liquid
  class SetTag < Tag
    attr_reader :to, :from

    def initialize(tag_name, markup, parse_context)
      super
      parse_context.require_closures!
      parser = parse_context.new_parser(markup)
      @to = parser.consume(:id)
      parser.consume(:assign)
      raise SyntaxError, "Expected set initializer" if parser.look(:end_of_string)

      @from = Variable.new(parser, parse_context)
    end

    def render_to_output_buffer(context, output)
      value = if context.variable_defined?(@to)
        @from.render(context)
      else
        context.stack(@to => nil) { @from.render(context) }
      end
      context.resource_limits.increment_assign_score(Assign.assign_score_of(value))
      context.set_local(@to, value)
      output
    end

    def blank?
      true
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.from]
      end
    end
  end
end
