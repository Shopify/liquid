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

    def render_to_output_buffer(context, output)
      previous_output_size = output.bytesize
      super
      context.scopes.last[@to] = output
      context.resource_limits.assign_score += (output.bytesize - previous_output_size)
      output
    end

    def format(left, right)
      output = "{%#{"-" if left} capture #{@to} #{"-" if right}%}"
      output << @body.format("")
      output << "{%#{"-" if left} endcapture #{"-" if right}%}"
    end

    def blank?
      true
    end
  end

  Template.register_tag('capture'.freeze, Capture)
end
