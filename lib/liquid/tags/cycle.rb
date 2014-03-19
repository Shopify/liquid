module Liquid
  # Cycle is usually used within a loop to alternate between values, like colors or DOM classes.
  #
  #   {% for item in items %}
  #     <div class="{% cycle 'red', 'green', 'blue' %}"> {{ item }} </div>
  #   {% end %}
  #
  #    <div class="red"> Item one </div>
  #    <div class="green"> Item two </div>
  #    <div class="blue"> Item three </div>
  #    <div class="red"> Item four </div>
  #    <div class="green"> Item five</div>
  #
  class Cycle < Tag
    SimpleSyntax = /\A#{QuotedFragment}+/o
    NamedSyntax  = /\A(#{QuotedFragment})\s*\:\s*(.*)/o

    def initialize(tag_name, markup, tokens)
      case markup
      when NamedSyntax
        @variables = variables_from_string($2)
        @name = $1
      when SimpleSyntax
        @variables = variables_from_string(markup)
        @name = "'#{@variables.to_s}'"
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.cycle"))
      end
      super
    end

    def render(output, context)
      context.registers[:cycle] ||= Hash.new(0)

      context.stack do
        key = context[@name]
        iteration = context.registers[:cycle][key]
        output << context[@variables[iteration]].to_s
        iteration += 1
        iteration  = 0  if iteration >= @variables.size
        context.registers[:cycle][key] = iteration
      end
    end

    def blank?
      false
    end

    private
    def variables_from_string(markup)
      markup.split(',').collect do |var|
        var =~ /\s*(#{QuotedFragment})\s*/o
        $1 ? $1 : nil
      end.compact
    end
  end

  Template.register_tag('cycle', Cycle)
end
