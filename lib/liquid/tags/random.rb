
module Liquid

  #Select random block separated by -OR-
  #i.e.
  # {% random %}
  #   {% random %} One -OR- Two  -OR- Three {% endrandom %}
  #   -OR-
  #   {% if false %}
  #      Last
  #   {% else %}
  #      LastElse
  #   {% endif %}
  #   -OR-
  #     End Last
  # {% endrandom %}" 
  #
  #Output: 'One' or 'LastElse' or 'End Last'
  #
  class Random < Block

    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      value = super.split('-OR-')
      return value[rand(value.length)]
    end

  end

  Template.register_tag('random', Random)
end
