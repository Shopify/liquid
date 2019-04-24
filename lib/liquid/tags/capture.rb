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
        @to = $1
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.capture"))
      end
    end

    def render_to_output_buffer(context)
      previous_output_size = context.output.bytesize
      super
      context.scopes.last[@to] = context.output
      context.resource_limits.assign_score += (context.output.bytesize - previous_output_size)
      context.output
    end

    def blank?
      true
    end
  end

  Template.register_tag('capture'.freeze, Capture)
end
