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
    NamedSyntax  = /\A(#{QuotedFragment})\s*\:\s*(.*)/om

    attr_reader :variables

    def initialize(tag_name, markup, options)
      super
      case markup
      when NamedSyntax
        @variables = variables_from_string($2)
        @name = Expression.parse($1)
      when SimpleSyntax
        @variables = variables_from_string(markup)
        @name = @variables.to_s
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.cycle".freeze))
      end
    end

    def format(left, right)
      output = "{%#{"-" if left} cycle "
      output << "#{Expression.format(@name)}: " unless @name == @variables.to_s
      first = true
      @variables.each do |variable|
        output << ", " unless first
        output << Expression.format(variable)
        first = false
      end
      output << " #{"-" if right}%}"
    end

    def render_to_output_buffer(context, output)
      context.registers[:cycle] ||= {}

      context.stack do
        key = context.evaluate(@name)
        iteration = context.registers[:cycle][key].to_i

        val = context.evaluate(@variables[iteration])

        if val.is_a?(Array)
          val = val.join
        elsif !val.is_a?(String)
          val = val.to_s
        end

        output << val

        iteration += 1
        iteration  = 0 if iteration >= @variables.size
        context.registers[:cycle][key] = iteration
      end

      output
    end

    private

    def variables_from_string(markup)
      markup.split(',').collect do |var|
        var =~ /\s*(#{QuotedFragment})\s*/o
        $1 ? Expression.parse($1) : nil
      end.compact
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        Array(@node.variables)
      end
    end
  end

  Template.register_tag('cycle', Cycle)
end
