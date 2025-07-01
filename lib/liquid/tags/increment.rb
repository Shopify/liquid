# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category variable
  # @liquid_name increment
  # @liquid_summary
  #   Creates a new variable, with a default value of 0, that's increased by 1 with each subsequent call.
  # @liquid_description
  #   Variables that are declared with `increment` are unique to the [layout](/themes/architecture/layouts), [template](/themes/architecture/templates),
  #   or [section](/themes/architecture/sections) file that they're created in. However, the variable is shared across
  #   [snippets](/themes/architecture/snippets) included in the file.
  #
  #   Similarly, variables that are created with `increment` are independent from those created with [`assign`](/docs/api/liquid/tags/assign)
  #   and [`capture`](/docs/api/liquid/tags/capture). However, `increment` and [`decrement`](/docs/api/liquid/tags/decrement) share
  #   variables.
  # @liquid_syntax
  #   {% increment variable_name %}
  # @liquid_syntax_keyword variable_name The name of the variable being incremented.
  class Increment < Tag
    attr_reader :variable_name

    def initialize(tag_name, markup, options)
      super
      @variable_name = markup.strip
    end

    def render_to_output_buffer(context, output)
      counter_environment = context.environments.first
      value = counter_environment[@variable_name] || 0
      counter_environment[@variable_name] = value + 1

      output << value.to_s
      output
    end
  end
end
