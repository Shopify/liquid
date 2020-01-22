require 'ap'

require 'pry'

require 'stackprof'

AwesomePrint.defaults = {
  raw: true
}

module Liquid
  Liquid::BlockBody.class_eval do
    def render_to_output_buffer(context, output)

      ruby = Compiler.compile(@nodelist)
      
      if false
        puts
        puts "--------------------------- GENERATED RUBY -"
        line_number = 1
        puts(ruby.lines.map do |line|
          "#{line_number}\t#{line}".tap { line_number += 1}
        end)
        puts "--------------------------- /GENERATED RUBY -"
      end

      instructions = RubyVM::InstructionSequence.compile(ruby)

      output_io = StringIO.new
      instructions.eval.call(output_io, context, Condition)

      output << output_io.string
    end
  end

  class SuperfluidError < Exception
  end

  class Output
    attr_reader :string, :indent_level

    def initialize(initial_indent)
      @string = ''.dup
      @indent_level = initial_indent
      @indent_str = " " * initial_indent * 2
    end

    def line(string)
      @string << @indent_str << string << "\n"
    end

    def echo(string)
      output << "liquid_out.write(to_output(#{string}))"
    end

    def indent(&block)
      output.indent(&block)
    end

    def indent
      @indent_level += 1
      @indent_str = " " * @indent_level * 2
      yield
      @indent_level -= 1
      @indent_str = " " * @indent_level * 2
    end
  end

  class Compiler
    class << self
      def compile(template)
        compiler = new
        compiler.compile(template)
        compiler.ruby
      end
    end

    def initialize
      @variables = Set.new
      @output = Output.new(2)
      @blank = false
    end

    def ruby
      [
        header,
        @output.string,
        trailer
      ].join("\n")
    end


    def header
      <<~RUBY
      module Warning
        def warn(*)
        end
      end

      class ForloopDrop
        def initialize(name, length, parentloop)
          @name = name
          @length = length
          @parentloop = parentloop
          @index = 0
        end

        attr_accessor :parentloop

        def [](value)
          case value
          when "length"
            @length
          when "name"
            @name
          when "index"
            @index + 1
          when "index0"
            @index
          when "rindex"
            @length - @index
          when "rindex0"
            @length - @index - 1
          when "first"
            @index == 0
          when "last"
            @index == @length - 1
          when "parentloop"
            @parentloop
          end
        end

        def to_liquid
          self
        end

        def key?(*)
          true
        end

        private

        def increment!
          @index += 1
        end
      end

      def slice_collection(collection, from, limit)
        to = if limit.nil?
          nil
        else
          limit + from
        end

        if (from != 0 || !to.nil?) && collection.respond_to?(:load_slice)
          collection.load_slice(from, to)
        else
          slice_collection_using_each(collection, from, to)
        end
      end

      def slice_collection_using_each(collection, from, to)
        segments = []
        index = 0

        if collection.is_a?(String)
          return collection.empty? ? [] : [collection]
        end
        return [] unless collection.respond_to?(:each)

        collection.each do |item|
          if to && to <= index
            break
          end

          if from <= index
            segments << item
          end

          index += 1
        end

        segments
      end

      def apply_operator(left, operator, right)
        if left.respond_to?(operator) && right.respond_to?(operator) && !left.is_a?(Hash) && !right.is_a?(Hash)
          begin
            left.send(operator, right)
          rescue ::ArgumentError => e
            raise @context.raise_argument_error(e.message)
          end
        end
      end

      def contains?(left, right)
        if left && right && left.respond_to?(:include?)
          right = right.to_s if left.is_a?(String)
          left.include?(right)
        else
          false
        end
      end

      class GlobalVariableLookup
        def method_missing(method_name, *)
          nil
        end

        def to_output(value)
          output = if value.is_a?(Array)
            value.join
          elsif value == nil
          else
            value.to_s
          end
          @context.apply_global_filter(output)
        end

        def run(liquid_out, context, condition)
          @condition = condition
          @context = context
          @for_offsets = {}
          @cycle_values = {}
          @context.registers[:for_stack] = []
          @context.registers[:cycle] ||= {}
          @if_changed_last = nil
          @prev_output_size = 0
          #{hoisted_variables}
      RUBY
    end

    def trailer
      <<~RUBY
          end
        end
        GlobalVariableLookup.new.method(:run)
      RUBY
    end

    def hoisted_variables
      @variables.map do |variable|
        normal_name = unvar(variable)
        "#{variable} = @context.find_variable(#{normal_name.inspect}, raise_on_not_found: false)"
      end.join("\n")
    end

    def compile(node)
      old_blank = @blank
      @blank = if node.respond_to?(:blank?)
        node.blank?
      elsif !(node.is_a?(String) && node =~ /\A\s*\z/)
        false
      else
        @blank
      end

      case node
      when Liquid::Document, Liquid::BlockBody
        node.nodelist.collect(&method(:compile))
      when Array
        node.collect(&method(:compile))
      when Liquid::Variable
        compile_variable(node)
      when Liquid::For
        compile_for(node)
      when Liquid::If
        compile_if(node)
      when Liquid::Ifchanged
        compile_if_changed(node)
      when Liquid::Template
        compile(node.root)
      when Liquid::Assign
        compile_assign(node)
      when Liquid::Case
        compile_case(node)
      when Liquid::Capture
        compile_capture(node)
      when String
        compile_echo_literal(node)
      when Liquid::Break
        line "break" if @in_loop
      when Liquid::Continue
        line "next" if @in_loop
      when Liquid::Cycle
        compile_cycle(node)
      when Liquid::Raw
        compile_raw(node)
      when Liquid::Increment
        compile_increment(node)
      when Liquid::Decrement
        compile_decrement(node)
      when Liquid::Comment
      else
        raise SuperfluidError, "Unknown node type #{node.inspect}"
      end

      @blank = old_blank
    end

    def compile_for(node)
      variable_name = node.variable_name

      collection_name = node.collection_name

      iter_target_expr = case collection_name
      when Liquid::VariableLookup
        make_variable_lookup_expr(collection_name)
      when Range
        collection_name
      when Liquid::RangeLookup
        start_expr = make_variable_expr(collection_name.start_obj)
        end_expr = make_variable_expr(collection_name.end_obj)
        line "start = #{start_expr}"
        line "@context.raise_argument_error('bad value for range') unless start.respond_to?(:to_i)"
        line "start = #{start_expr}.to_i"

        line "finish = #{end_expr}"
        line "@context.raise_argument_error('bad value for range') unless finish.respond_to?(:to_i)"
        line "finish = #{end_expr}.to_i"

        "start..finish"
      when Liquid::Expression::MethodLiteral
        '[]'
      else
        raise SuperfluidError, "Unknown iteration target: #{collection_name.inspect}"
      end

      from_expr = if node.from == :continue
        "@for_offsets['#{node.name}'].to_i"
      elsif node.from
        make_variable_expr(node.from)
      else
        '0'
      end

      limit_expr = node.limit ? make_variable_expr(node.limit) : 'nil'
      line "from = #{from_expr}"
      line "limit = #{limit_expr}"
      line "@context.raise_argument_error('invalid integer') unless from.is_a?(Integer)"
      line "@context.raise_argument_error('invalid integer') unless !limit || limit.is_a?(Integer)"

      line "segment = slice_collection(#{iter_target_expr}, from, limit)"
      line "segment.reverse!" if node.reversed

      forloop = var('forloop')
      hoist_var('forloop')
      line "#{forloop} = ForloopDrop.new('#{node.name}', segment.length, #{forloop})"

      line "if segment.any?"
      indent do
        line "segment.each do |#{var(variable_name)}|"
          indent do
            line "@context['forloop'] = #{forloop}"


            old_in_loop = @in_loop
            compile(node.for_block)
            @in_loop = old_in_loop

            line "#{forloop}.send(:increment!)"
          end
        line "end"
      end
      line "else"
      indent do
        compile(node.else_block) if node.else_block
      end
      line "end"

      line "@for_offsets['#{node.name}'] = from + segment.length"
      line "#{forloop} = #{forloop}.parentloop"
    end

    def compile_if(node)
      if_condition = node.blocks.first
      line "if #{make_condition_expr(if_condition)}"
      indent { if_condition.attachment.nodelist.each(&method(:compile)) }

      node.blocks.drop(1).each do |condition|
        if condition.left != nil
          line "elsif #{make_condition_expr(condition)}"
        else
          line "else"
        end
        indent { condition.attachment.nodelist.each(&method(:compile)) }
      end

      line "end"
    end

    def compile_if_changed(node)
      line "if_changed = lambda do |; liquid_out|"
      indent do
        line "liquid_out = StringIO.new"
        node.nodelist.each(&method(:compile))
        line "liquid_out.string"
      end
      line "end.call"

      line "if if_changed != @if_changed_last"
      indent { echo "if_changed" }
      line "end"

      line "@if_changed_last = if_changed"
    end

    def compile_capture(node)
      line "#{var(node.to)} = lambda do |; liquid_out|"
      hoist_var(node.to)
      indent do
        line "liquid_out = StringIO.new"
        node.nodelist.each(&method(:compile))
        line "liquid_out.string"
      end
      line "end.call"
    end

    def make_condition_expr(node)
      condition = make_sub_condition_expr(node)
      if node.child_condition
        "(#{condition} #{node.child_relation} #{make_condition_expr(node.child_condition)})"
      else
        condition
      end
    end

    def make_sub_condition_expr(node)
      return make_variable_expr(node.left) unless node.operator

      operator = node.operator
      operator = "!=" if operator == "<>"

      if operator == "=="
        if node.left.is_a?(Liquid::Expression::MethodLiteral) &&
          node.right.is_a?(Liquid::Expression::MethodLiteral)
          return "false"
        elsif node.right.is_a?(Liquid::Expression::MethodLiteral)
          target = make_variable_expr(node.left)
          message = node.right.method_name.inspect
          return "#{target}.respond_to?(#{message}) ? #{target}.send(#{message}) : nil"
        elsif node.left.is_a?(Liquid::Expression::MethodLiteral)
          target = make_variable_expr(node.right)
          message = node.left.method_name.inspect
          return "#{target}.respond_to?(#{message}) ? #{target}.send(#{message}) : nil"
        end
      end

      left = make_variable_expr(node.left)
      right = make_variable_expr(node.right)

      case operator
      when "contains"
        "contains?(#{left}, #{right})"
      else
        "apply_operator(#{left}, #{operator.inspect}, #{right})"
      end
    end

    def compile_case(node)
      line 'if false' # HACK
      else_nodes, if_nodes = node.blocks.partition { |n| n.is_a?(Liquid::ElseCondition) }
      raise SuperfluidError, 'Too many else nodes' if else_nodes.count > 1
      else_node = else_nodes.first

      if_nodes.each do |condition|
        left = make_variable_expr(condition.left)
        right = make_variable_expr(condition.right)
        line "elsif #{left} #{condition.operator} #{right}"
        indent { condition.attachment.nodelist.each(&method(:compile)) }
      end

      if else_node
        line "else"
        indent { else_node.attachment.nodelist.each(&method(:compile)) }
      end

      line "end"
    end

    def compile_cycle(node)
      key = node.name
      key = key.name if key.is_a?(Liquid::VariableLookup)

      line "key = #{key.inspect}"
      line "iteration = context.registers[:cycle][key].to_i"
      line "@cycle_values[key] ||= #{node.variables}"

      line "val = @cycle_values[key][iteration]"
      echo 'val'
      line "context.registers[:cycle][key] = (iteration + 1) % #{node.variables.size}"
    end

    def compile_raw(node)
      echo "#{node.body.inspect}"
    end

    def compile_increment(node)
      line "value = context.environments.first[#{node.variable.inspect}] ||= 0"
      line "@context.environments.first[#{node.variable.inspect}] = value + 1"
      echo "value"
    end

    def compile_decrement(node)
      line "value = context.environments.first[#{node.variable.inspect}] ||= 0"
      line "value -= 1"
      line "@context.environments.first[#{node.variable.inspect}] = value"
      echo "value"
    end

    def compile_echo_literal(node)
      echo node.inspect
    end

    def compile_variable(variable)
      echo make_variable_expr(variable)
    end

    def compile_assign(node)
      from_expr = case node.from
      when Liquid::Variable
        make_variable_expr(node.from)
      else
        raise SuperfluidError, "Unknown assignment `from`: #{node.from.inspect}"
      end

      line "#{var(node.to)} = #{from_expr}"
      hoist_var(node.to)
    end

    def make_variable_expr(variable)
      case variable
      when Liquid::Variable
        base_expression = case variable.name
        when TrueClass, FalseClass, Numeric, String
          variable.name.inspect
        when Liquid::VariableLookup
          make_variable_lookup_expr(variable.name)
        when NilClass, Liquid::Expression::MethodLiteral
          'nil'
        else
          raise SuperfluidError, "Invalid variable name: #{variable.name.inspect}"
          derp "Bad var name", variable.name
        end
        variable.filters.inject(base_expression) do |inner, (filter_name, positional_args, keyword_args)|
          filter_args = positional_args.map(&method(:make_variable_expr))

          if keyword_args
             filter_args << "{ " + keyword_args
              .transform_values(&method(:make_variable_expr))
              .collect { |(key, value)| "#{key.inspect} => #{value}" }
              .join(", ") + " }"
          end

          "context.strainer.invoke(#{filter_name.inspect}, #{inner}, *[#{filter_args.join(", ")}])"
        end
      when Liquid::VariableLookup
        make_variable_lookup_expr(variable)
      when TrueClass, FalseClass, Numeric, String
        variable.inspect
      when NilClass
        'nil'
      else
        raise SuperfluidError, "Unknown expression type: #{variable.inspect}"
      end
    end

    def make_variable_lookup_expr(variable_lookup)
      base_expr = var(variable_lookup.name)
      hoist_var(variable_lookup.name)
      return base_expr if variable_lookup.lookups.empty?
      
      expr = Output.new(output.indent_level)
      expr.line "(begin"
      expr.indent do
        expr.line "inner = #{base_expr}"
        variable_lookup.lookups.each_with_index do |lookup, i|
          lookup_expr = lookup.inspect
          expr.line "inner = if inner.respond_to?(:[]) && ((inner.respond_to?(:key?) && inner.key?(#{lookup_expr})) || (inner.respond_to?(:fetch) && #{lookup_expr}.is_a?(Integer)))"
          expr.indent do
            expr.line "inner[#{lookup_expr}].to_liquid"
          end
          if variable_lookup.command_flags & (1 << i) != 0
            expr.line "elsif inner.respond_to?(#{lookup.inspect})"
            expr.indent do
              expr.line "inner.#{lookup}.to_liquid"
            end
          end
          expr.line "end"
        end
      end
      expr.line "end)"
      expr.string.strip
    end

    private

    def line(string)
      output.line(string)
    end

    def echo(string)
      unless @blank
        line "liquid_out.write(to_output(#{string}))"
      end
    end

    def indent(&block)
      output.indent(&block)
    end

    def var(name)
      name = name
        .gsub('_', '__')
        .gsub('-', '_')
      "__liquid_#{name}"
    end

    def unvar(name)
      name
        .delete_prefix('__liquid_')
        .gsub(/([^_])_([^_])/) { "#$1-#$2" }
        .gsub('__', '_')
    end

    def hoist_var(name)
      @variables << var(name)
    end

    attr_reader :output
  end
end
