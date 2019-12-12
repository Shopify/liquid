# frozen_string_literal: true

module Liquid
  # Assign sets a variable in your template.
  #
  #   {% assign foo = 'monkey' %}
  #
  # You can then use the variable later in the page.
  #
  #  {{ foo }}
  #
  class Assign < Tag
    Syntax = /(#{VariableSignature}+)\s*=\s*(.*)\s*/om

    attr_reader :to, :from

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @to   = Regexp.last_match(1)
        @from = Variable.new(Regexp.last_match(2), options)
      else
        raise SyntaxError, options[:locale].t('errors.syntax.assign')
      end
    end

    def render_to_output_buffer(context, output)
      val = @from.render(context)
      context.scopes.last[@to] = val
      context.resource_limits.assign_score += assign_score_of(val)
      output
    end

    def blank?
      true
    end

    private

    def assign_score_of(val)
      if val.instance_of?(String)
        val.bytesize
      elsif val.instance_of?(Array) || val.instance_of?(Hash)
        sum = 1
        # Uses #each to avoid extra allocations.
        val.each { |child| sum += assign_score_of(child) }
        sum
      else
        1
      end
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        [@node.from]
      end
    end
  end

  Template.register_tag('assign', Assign)
end
