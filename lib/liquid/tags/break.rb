module Liquid
  # Break tag to be used to break out of a for loop.
  #
  # == Basic Usage:
  #    {% for item in collection %}
  #      {% if item.condition %}
  #        {% break %}
  #      {% endif %}
  #    {% endfor %}
  #
  class Break < Tag
    def interrupt
      BreakInterrupt.new
    end

    def format(left, right)
      "{%#{"-" if left} break #{"-" if right}%}"
    end
  end

  Template.register_tag('break'.freeze, Break)
end
