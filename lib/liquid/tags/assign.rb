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
        @from = Variable.new($2,options)
        @from.line_number = line_number
      else
        raise SyntaxError.new options[:locale].t("errors.syntax.assign".freeze)
      end
    end

    def render(context)
      val = @from.render(context)
      context.scopes.last[@to] = val
      context.increment_used_resources(:assign_score_current, val)
      ''.freeze
    end

    def blank?
      true
    end
  end

  Template.register_tag('assign'.freeze, Assign)
end
