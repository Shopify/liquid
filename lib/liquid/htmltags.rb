module Liquid
  class TableRow < Block
    Syntax = /(\w+)\s+in\s+(#{QuotedFragment}+)/o

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @variable_name = $1
        @collection_name = $2
        @idx_i = "#{$1}-#{$2}-i"
        @idx_col = "#{$1}-#{$2}-c"
        @attributes = {}
        markup.scan(TagAttributes) do |key, value|
          @attributes[key] = value
        end
      else
        raise SyntaxError.new("Syntax Error in 'table_row loop' - Valid syntax: table_row [item] in [collection] cols=3")
      end

      super
    end

    def render(context)
      context.registers[:tablerowloop] ||= Hash.new(0)

      collection = context[@collection_name] or return ''

      from = @attributes['offset'] ? context[@attributes['offset']].to_i : 0
      to = @attributes['limit'] ? from + context[@attributes['limit']].to_i : nil

      collection = Utils.slice_collection_using_each(collection, from, to)

      length = collection.length

      cols = context[@attributes['cols']].to_i

      row = 1
      col = 0

      result = ["<tr class=\"row1\">\n"]
      context.stack do

        context.registers[:tablerowloop][@idx]
        context['tablerowloop'] = lambda { Tablerowloop.new(@idx_i, @idx_col, length) }
        collection.each_with_index do |item, index|
          context.registers[:tablerowloop][@idx_i] = index
          context.registers[:tablerowloop][@idx_col] = col
          context[@variable_name] = item          

          col += 1

          result << "<td class=\"col#{col}\">" << render_all(@nodelist, context) << '</td>'

          if col == cols and not (index == length - 1)
            col  = 0
            row += 1
            result << "</tr>\n<tr class=\"row#{row}\">"
          end

        end
      end
      result << "</tr>\n"
      result
    end



    private

      class Tablerowloop < Liquid::Drop
        attr_accessor :length

        def initialize(idx_i, idx_col, length)
          @idx_i, @idx_col, @length = idx_i, idx_col, length
        end

        def index
          @context.registers[:tablerowloop][@idx_i] + 1
        end

        def index0
          @context.registers[:tablerowloop][@idx_i]
        end

        def rindex
          length - @context.registers[:tablerowloop][@idx_i]
        end

        def rindex0
          length - @context.registers[:tablerowloop][@idx_i] - 1
        end

        def first
          (@context.registers[:tablerowloop][@idx_i] == 0)
        end

        def last
          (@context.registers[:tablerowloop][@idx_i] == length - 1)
        end

        def col
          @context.registers[:tablerowloop][@idx_col] + 1
        end

        def col0
          @context.registers[:tablerowloop][@idx_col]
        end

        def col_first
          (@context.registers[:tablerowloop][@idx_col] == 0)
        end

        def col_last
          (@context.registers[:tablerowloop][@idx_col] == cols - 1)
        end
      end
  end

  Template.register_tag('tablerow', TableRow)
end
