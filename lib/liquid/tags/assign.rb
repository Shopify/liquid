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
    Syntax = /(#{VariableSignature}+)\s*=\s*(.*)\s*/o

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @to = $1
        @from = Variable.new($2)
      else
        raise SyntaxError.new options[:locale].t("errors.syntax.assign")
      end

      super
    end

    def render(context, output)
      val = @from.evaluate(context)
      context.scopes.last[@to] = val
      context.increment_used_resources(:assign_score_current, val)
    end

    def blank?
      true
    end
  end

  Template.register_tag('assign', Assign)
end
