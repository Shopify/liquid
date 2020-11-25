# frozen_string_literal: true

module Liquid
  # Capture stores the result of a block into a variable without rendering it inplace.
  #
  #   {% capture heading %}
  #     Monkeys!
  #   {% endcapture %}
  #   ...
  #   <h1>{{ heading }}</h1>
  #
  # Capture is useful for saving content for use later in your template, such as
  # in a sidebar or footer.
  #
  class Capture < Block
    Syntax = /(#{VariableSignature}+)/o

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @to = Regexp.last_match(1)
      else
        raise SyntaxError, options[:locale].t("errors.syntax.capture")
      end
    end

    def render_to_output_buffer(context, output)
      context.resource_limits.with_capture do
        capture_output = render(context)
        context.scopes.last[@to] = capture_output
      end
      output
    end

    def blank?
      true
    end
  end

  Template.register_tag('capture', Capture)
end
