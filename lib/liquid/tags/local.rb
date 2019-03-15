require_relative 'assign'

module Liquid
  # Local sets a variable in the current scope.
  #
  #   {% local foo = 'monkey' %}
  #
  # You can then use the variable later in the scope.
  #
  # {% if true %}
  #   {% local foo = 'monkey' %}
  #   {{ foo }} outputs monkey
  # {% endif %}
  # {{ foo }} outputs nothing
  #
  class Local < Assign
    def self.syntax_error_translation_key
      "errors.syntax.local".freeze
    end

    def render(context)
      val = @from.render(context)
      context[@to] = val
      context.resource_limits.assign_score += assign_score_of(val)
      ''.freeze
    end
  end

  Template.register_tag('local'.freeze, Local)
end
