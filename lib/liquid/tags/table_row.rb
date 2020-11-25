# frozen_string_literal: true

module Liquid
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

      from = @attributes.key?('offset') ? context.evaluate(@attributes['offset']).to_i : 0
      to   = @attributes.key?('limit')  ? from + context.evaluate(@attributes['limit']).to_i : nil

      collection = Utils.slice_collection(collection, from, to)
      length     = collection.length

      cols = context.evaluate(@attributes['cols']).to_i

      output << "<tr class=\"row1\">\n"
      context.stack do
        tablerowloop = Liquid::TablerowloopDrop.new(length, cols)
        context['tablerowloop'] = tablerowloop

        collection.each do |item|
          context[@variable_name] = item

          output << "<td class=\"col#{tablerowloop.col}\">"
          super
          output << '</td>'

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
  end

  Template.register_tag('tablerow', TableRow)
end
