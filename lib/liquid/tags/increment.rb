# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category variable
  # @liquid_name increment
  # @liquid_summary
  #   Creates a new variable, with a default value of 0, that's increased by 1 with each subsequent call.
  # @liquid_desription
  #   Variables that are declared with `increment` are unique to the file ([layout](/themes/architecture/layouts), [section](/themes/architecture/sections),
  #   or [template](/themes/architecture/templates)) that they're created in. However, these variables are shared across
  #   [snippets](/themes/architecture#snippets) inside each of those files.
  #
  #   Similarly, variables that are created with `increment` are are unique to those created with [`assign`](/api/liquid/tags#assign)
  #   and [`capture`](/api/liquid/tags#capture). However, these variables are shared with variables created with
  #   [`decrement`](/api/liquid/tags#decrement).
  # @liquid_syntax
  #   {% increment variable_name %}
  # @liquid_syntax_keyword variable_name The name of the variable being decremented.
  class Increment < Tag
    def initialize(tag_name, markup, options)
      super
      @variable = markup.strip
    end

    def render_to_output_buffer(context, output)
      value = context.environments.first[@variable] ||= 0
      context.environments.first[@variable] = value + 1

      output << value.to_s
      output
    end
  end

  Template.register_tag('increment', Increment)
end
