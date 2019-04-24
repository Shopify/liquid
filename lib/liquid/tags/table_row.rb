module Liquid
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o

    attr_reader :variable_name, :collection_name, :attributes

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @variable_name = $1
        @collection_name = Expression.parse($2)
        @attributes = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = Expression.parse(value)
        end
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.table_row".freeze))
      end
    end

    def render_to_output_buffer(context)
      collection = context.evaluate(@collection_name) or return context.output

      from = @attributes.key?('offset'.freeze) ? context.evaluate(@attributes['offset'.freeze]).to_i : 0
      to = @attributes.key?('limit'.freeze) ? from + context.evaluate(@attributes['limit'.freeze]).to_i : nil

      collection = Utils.slice_collection(collection, from, to)

      length = collection.length

      cols = context.evaluate(@attributes['cols'.freeze]).to_i

      context.output << "<tr class=\"row1\">\n"
      context.stack do
        tablerowloop = Liquid::TablerowloopDrop.new(length, cols)
        context['tablerowloop'.freeze] = tablerowloop

        collection.each do |item|
          context[@variable_name] = item

          context.output << "<td class=\"col#{tablerowloop.col}\">"
          super
          context.output << '</td>'

          if tablerowloop.col_last && !tablerowloop.last
            context.output << "</tr>\n<tr class=\"row#{tablerowloop.row + 1}\">"
          end

          tablerowloop.send(:increment!)
        end
      end

      context.output << "</tr>\n"
      context.output
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        super + @node.attributes.values + [@node.collection_name]
      end
    end
  end

  Template.register_tag('tablerow'.freeze, TableRow)
end
