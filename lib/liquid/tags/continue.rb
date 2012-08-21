module Liquid

  # Continue tag to be used to break out of a for loop.
  #
  # == Basic Usage:
  #    {% for item in collection %}
  #      {% if item.condition %}
  #        {% continue %}
  #      {% endif %}
  #    {% endfor %}
  # 
  class Continue < Tag

    ##
    # Add an interrupt to context errors so a for loop can check
    # for interrupts. 
    def render(context)
      context.handle_error(ContinueInterrupt.new)
    end
    
  end

  Template.register_tag('continue', Continue)
end
