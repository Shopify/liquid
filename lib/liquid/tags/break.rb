# frozen_string_literal: true

module Liquid
  # Break tag to be used to break out of a for loop.
  #
  # == Iteration usage:
  #    {% for item in collection %}
  #      {% if item.condition %}
  #        {% break %}
  #      {% endif %}
  #    {% endfor %}
  #
  # == Theme file rendering usage:
  #    {% if condition %}
  #      {% break %}
  #    {% endif %}
  #
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category iteration
  # @liquid_name break
  # @liquid_summary
  #   Stops a [`for` loop](/docs/api/liquid/tags/for) from iterating, or stops the
  #   rest of a file from rendering when used outside of a loop.
  # @liquid_description
  #   Inside a `for` or `tablerow` loop, `break` stops the loop.
  #
  #   Outside of a loop, `break` stops the rest of the current file from
  #   rendering. Sections, blocks, and snippets each render in their own context, so
  #   rendering continues normally in the file that rendered them.
  # @liquid_syntax
  #   {% break %}
  class Break < Tag
    INTERRUPT = BreakInterrupt.new.freeze

    def render_to_output_buffer(context, output)
      context.push_interrupt(INTERRUPT)
      output
    end
  end
end
