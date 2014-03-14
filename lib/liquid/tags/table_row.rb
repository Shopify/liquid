module Liquid
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @variable_name = $1
        @collection_name = $2
        @attributes = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.table_row"))
      end

      super
    end

    def render(context, output)
      collection = context[@collection_name] or return ''

      from = @attributes['offset'] ? context[@attributes['offset']].to_i : 0
      to = @attributes['limit'] ? from + context[@attributes['limit']].to_i : nil

      collection = Utils.slice_collection(collection, from, to)

      length = collection.length

      cols = context[@attributes['cols']].to_i

      row = 1
      col = 0

      output << "<tr class=\"row1\">\n"
      context.stack do

        collection.each_with_index do |item, index|
          context[@variable_name] = item
          context['tablerowloop'] = {
            'length'  => length,
            'index'   => index + 1,
            'index0'  => index,
            'col'     => col + 1,
            'col0'    => col,
            'index0'  => index,
            'rindex'  => length - index,
            'rindex0' => length - index - 1,
            'first'   => (index == 0),
            'last'    => (index == length - 1),
            'col_first' => (col == 0),
            'col_last'  => (col == cols - 1)
          }


          col += 1

          output << "<td class=\"col#{col}\">"
          super
          output << '</td>'

          if col == cols and (index != length - 1)
            col  = 0
            row += 1
            output << "</tr>\n<tr class=\"row#{row}\">"
          end

        end
      end
      output << "</tr>\n"
    end
  end

  Template.register_tag('tablerow', TableRow)
end
