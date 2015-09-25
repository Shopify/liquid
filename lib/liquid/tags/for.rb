module Liquid
  # "For" iterates over an array or collection.
  # Several useful variables are available to you within the loop.
  #
  # == Basic usage:
  #    {% for item in collection %}
  #      {{ forloop.index }}: {{ item.name }}
  #    {% endfor %}
  #
  # == Advanced usage:
  #    {% for item in collection %}
  #      <div {% if forloop.first %}class="first"{% endif %}>
  #        Item {{ forloop.index }}: {{ item.name }}
  #      </div>
  #    {% else %}
  #      There is nothing in the collection.
  #    {% endfor %}
  #
  # You can also define a limit and offset much like SQL.  Remember
  # that offset starts at 0 for the first item.
  #
  #    {% for item in collection limit:5 offset:10 %}
  #      {{ item.name }}
  #    {% end %}
  #
  #  To reverse the for loop simply use {% for item in collection reversed %}
  #
  # == Available variables:
  #
  # forloop.name:: 'item-collection'
  # forloop.length:: Length of the loop
  # forloop.index:: The current item's position in the collection;
  #                 forloop.index starts at 1.
  #                 This is helpful for non-programmers who start believe
  #                 the first item in an array is 1, not 0.
  # forloop.index0:: The current item's position in the collection
  #                  where the first item is 0
  # forloop.rindex:: Number of items remaining in the loop
  #                  (length - index) where 1 is the last item.
  # forloop.rindex0:: Number of items remaining in the loop
  #                   where 0 is the last item.
  # forloop.first:: Returns true if the item is the first item.
  # forloop.last:: Returns true if the item is the last item.
  # forloop.parentloop:: Provides access to the parent loop, if present.
  #
  class For < Block
    Syntax = /\A(#{VariableSegment}+)\s+in\s+(#{QuotedFragment}+)\s*(reversed)?/o

    def initialize(tag_name, markup, options)
      super
      parse_with_selected_parser(markup)
      @for_block = BlockBody.new
    end

    def parse(tokens)
      return unless parse_body(@for_block, tokens)
      parse_body(@else_block, tokens)
    end

    def nodelist
      @else_block ? [@for_block, @else_block] : [@for_block]
    end

    def unknown_tag(tag, markup, tokens)
      return super unless tag == 'else'.freeze
      @else_block = BlockBody.new
    end

    def render(context)
      for_offsets = context.registers[:for] ||= Hash.new(0)
      for_stack = context.registers[:for_stack] ||= []

      parent_loop = for_stack.last
      for_stack.push(nil)

      collection = context.evaluate(@collection_name)
      collection = collection.to_a if collection.is_a?(Range)

      from = if @from == :continue
        for_offsets[@name].to_i
      else
        context.evaluate(@from).to_i
      end

      limit = context.evaluate(@limit)
      to    = limit ? limit.to_i + from : nil

      segment = Utils.slice_collection(collection, from, to)

      return render_else(context) if segment.empty?

      segment.reverse! if @reversed

      result = ''

      length = segment.length

      # Store our progress through the collection for the continue flag
      for_offsets[@name] = from + segment.length

      context.stack do
        segment.each_with_index do |item, index|
          context[@variable_name] = item
          loop_vars = {
            'name'.freeze       => @name,
            'length'.freeze     => length,
            'index'.freeze      => index + 1,
            'index0'.freeze     => index,
            'rindex'.freeze     => length - index,
            'rindex0'.freeze    => length - index - 1,
            'first'.freeze      => (index == 0),
            'last'.freeze       => (index == length - 1),
            'parentloop'.freeze => parent_loop
          }

          context['forloop'.freeze] = loop_vars
          for_stack[-1] = loop_vars

          result << @for_block.render(context)

          # Handle any interrupts if they exist.
          if context.interrupt?
            interrupt = context.pop_interrupt
            break if interrupt.is_a? BreakInterrupt
            next if interrupt.is_a? ContinueInterrupt
          end
        end
      end

      result
    ensure
      for_stack.pop
    end

    protected

    def lax_parse(markup)
      if markup =~ Syntax
        @variable_name = $1
        collection_name = $2
        @reversed = !!$3
        @name = "#{@variable_name}-#{collection_name}"
        @collection_name = Expression.parse(collection_name)
        markup.scan(TagAttributes) do |key, value|
          set_attribute(key, value)
        end
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.for".freeze))
      end
    end

    def strict_parse(markup)
      p = Parser.new(markup)
      @variable_name = p.consume(:id)
      raise SyntaxError.new(options[:locale].t("errors.syntax.for_invalid_in".freeze)) unless p.id?('in'.freeze)
      collection_name = p.expression
      @name = "#{@variable_name}-#{collection_name}"
      @collection_name = Expression.parse(collection_name)
      @reversed = p.id?('reversed'.freeze)

      while p.look(:id) && p.look(:colon, 1)
        unless attribute = p.id?('limit'.freeze) || p.id?('offset'.freeze)
          raise SyntaxError.new(options[:locale].t("errors.syntax.for_invalid_attribute".freeze))
        end
        p.consume
        set_attribute(attribute, p.expression)
      end
      p.consume(:end_of_string)
    end

    private

    def set_attribute(key, expr)
      case key
      when 'offset'.freeze
        @from = if expr == 'continue'.freeze
          :continue
        else
          Expression.parse(expr)
        end
      when 'limit'.freeze
        @limit = Expression.parse(expr)
      end
    end

    def render_else(context)
      @else_block ? @else_block.render(context) : ''.freeze
    end
  end

  Template.register_tag('for'.freeze, For)
end
