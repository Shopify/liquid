module Liquid
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o

    def initialize(tag_name, markup, options)
      super
      if markup =~ Syntax
        @variable_name = $1
        @collection_name = $2
        @attributes = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.table_row".freeze))
      end
    end

    def render(context)
      collection = context[@collection_name] or return ''.freeze

      from = @attributes['offset'.freeze] ? context[@attributes['offset'.freeze]].to_i : 0
      to = @attributes['limit'.freeze] ? from + context[@attributes['limit'.freeze]].to_i : nil

      collection = Utils.slice_collection(collection, from, to)

      length = collection.length

      cols = context[@attributes['cols'.freeze]].to_i

      row = 1
      col = 0

      result = "<tr class=\"row1\">\n"
      context.stack do

        collection.each_with_index do |item, index|
          context[@variable_name] = item
          context['tablerowloop'.freeze] = {
            'length'.freeze    => length,
            'index'.freeze     => index + 1,
            'index0'.freeze    => index,
            'col'.freeze       => col + 1,
            'col0'.freeze      => col,
            'rindex'.freeze    => length - index,
            'rindex0'.freeze   => length - index - 1,
            'first'.freeze     => (index == 0),
            'last'.freeze      => (index == length - 1),
            'col_first'.freeze => (col == 0),
            'col_last'.freeze  => (col == cols - 1)
          }


          col += 1

          result << "<td class=\"col#{col}\">" << super << '</td>'

          if col == cols and (index != length - 1)
            col  = 0
            row += 1
            result << "</tr>\n<tr class=\"row#{row}\">"
          end

        end
      end
      result << "</tr>\n"
      result
    end
  end

  Template.register_tag('tablerow'.freeze, TableRow)
end
