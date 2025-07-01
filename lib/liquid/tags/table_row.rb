# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category iteration
  # @liquid_name tablerow
  # @liquid_summary
  #   Generates HTML table rows for every item in an array.
  # @liquid_description
  #   The `tablerow` tag must be wrapped in HTML `<table>` and `</table>` tags.
  #
  #   > Tip:
  #   > Every `tablerow` loop has an associated [`tablerowloop` object](/docs/api/liquid/objects/tablerowloop) with information about the loop.
  # @liquid_syntax
  #   {% tablerow variable in array %}
  #     expression
  #   {% endtablerow %}
  # @liquid_syntax_keyword variable The current item in the array.
  # @liquid_syntax_keyword array The array to iterate over.
  # @liquid_syntax_keyword expression The expression to render.
  # @liquid_optional_param cols [number] The number of columns that the table should have.
  # @liquid_optional_param limit [number] The number of iterations to perform.
  # @liquid_optional_param offset [number] The 1-based index to start iterating at.
  # @liquid_optional_param range [untyped] A custom numeric range to iterate over.
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o

    attr_reader :variable_name, :collection_name, :attributes

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @variable_name   = Regexp.last_match(1)
        @collection_name = parse_expression(Regexp.last_match(2))
        @attributes      = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = parse_expression(value)
        end
      else
        raise SyntaxError, options[:locale].t("errors.syntax.table_row")
      end
    end

    def render_to_output_buffer(context, output)
      (collection = context.evaluate(@collection_name)) || (return '')

      from = @attributes.key?('offset') ? to_integer(context.evaluate(@attributes['offset'])) : 0
      to = @attributes.key?('limit') ? from + to_integer(context.evaluate(@attributes['limit'])) : nil

      collection = Utils.slice_collection(collection, from, to)
      length     = collection.length

      cols = @attributes.key?('cols') ? to_integer(context.evaluate(@attributes['cols'])) : length

      output << "<tr class=\"row1\">\n"
      context.stack do
        tablerowloop = Liquid::TablerowloopDrop.new(length, cols)
        context['tablerowloop'] = tablerowloop

        collection.each do |item|
          context[@variable_name] = item

          output << "<td class=\"col#{tablerowloop.col}\">"
          super
          output << '</td>'

          # Handle any interrupts if they exist.
          if context.interrupt?
            interrupt = context.pop_interrupt
            break if interrupt.is_a?(BreakInterrupt)
          end

          if tablerowloop.col_last && !tablerowloop.last
            output << "</tr>\n<tr class=\"row#{tablerowloop.row + 1}\">"
          end

          tablerowloop.send(:increment!)
        end
      end

      output << "</tr>\n"
      output
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        super + @node.attributes.values + [@node.collection_name]
      end
    end

    private

    def to_integer(value)
      value.to_i
    rescue NoMethodError
      raise Liquid::ArgumentError, "invalid integer"
    end
  end
end
