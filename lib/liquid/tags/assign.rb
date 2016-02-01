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

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @to = $1
        @from = Variable.new($2, options)
      else
        raise SyntaxError.new options[:locale].t("errors.syntax.assign".freeze)
      end
    end

    def render(context)
      val = @from.render(context)
      context.scopes.last[@to] = val
      context.resource_limits.assign_score += assign_score_of(val)
      ''.freeze
    end

    def blank?
      true
    end

    private

    def assign_score_of(val)
      if val.instance_of?(String)
        val.length
      elsif val.instance_of?(Array) || val.instance_of?(Hash)
        val.reduce(0) { |n, child| n + assign_score_of(child) }
      else
        1
      end
    end
  end

  Template.register_tag('assign'.freeze, Assign)
end
