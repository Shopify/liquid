# frozen_string_literal: true

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
    INTERRUPT = ContinueInterrupt.new.freeze

    def render_to_output_buffer(context, output)
      context.push_interrupt(INTERRUPT)
      output
    end
  end

  Template.register_tag('continue', Continue)
end
