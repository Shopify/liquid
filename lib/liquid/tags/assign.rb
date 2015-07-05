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

      inc = val.instance_of?(String) || val.instance_of?(Array) || val.instance_of?(Hash) ? val.length : 1
      context.resource_limits.assign_score += inc

      ''.freeze
    end

    def blank?
      true
    end
  end

  Template.register_tag('assign'.freeze, Assign)
end
