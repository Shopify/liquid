# frozen_string_literal: true

module Liquid
  class Let < Block
    attr_reader :to, :from, :parameters, :closure_body

    def initialize(tag_name, markup, parse_context)
      super
      parse_context.require_closures!
      parser = parse_context.new_parser(markup)
      @to = parser.consume(:id)
      if parser.consume?(:assign)
        raise SyntaxError, "Expected let initializer" if parser.look(:end_of_string)

        @from = Variable.new(parser, parse_context)
      else
        @parameters = parser.parameters.freeze
        parser.consume(:end_of_string)
      end
      parse_context.declare_local(@to)
    end

    def parse(tokens)
      return unless body_form?

      @closure_body = parse_closure_body(tokens, parameters: @parameters)
    end

    def body_form?
      @from.nil?
    end

    def nodelist
      body_form? ? super : Const::EMPTY_ARRAY
    end

    def render_to_output_buffer(context, output)
      value = body_form? ? @closure_body.bind(context) : @from.render(context)
      context.resource_limits.increment_assign_score(Assign.assign_score_of(value))
      context[@to] = value
      output
    end

    def blank?
      true
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        @node.body_form? ? [@node.closure_body] : [@node.from]
      end
    end
  end
end
