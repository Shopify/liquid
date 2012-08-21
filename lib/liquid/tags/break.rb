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

    ##
    # Add an interrupt to context errors so a for loop can check
    # for interrupts. 
    def render(context)
      context.handle_error(BreakInterrupt.new)
    end
    
  end

  Template.register_tag('break', Break)
end
