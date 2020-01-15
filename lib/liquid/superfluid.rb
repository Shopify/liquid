require 'ap'
require 'pry'

AwesomePrint.defaults = {
  raw: true
}

module Liquid

  Liquid::BlockBody.class_eval do
    def render_to_output_buffer(context, output)
      ruby = Compiler.compile(@nodelist)

      # puts
      # puts "--------------------------- GENERATED RUBY -"
      # puts ruby
      # puts "--------------------------- /GENERATED RUBY -"

      instructions = RubyVM::InstructionSequence.compile(ruby)

      output_io = StringIO.new
      instructions.eval.call(output_io, context)

      output << output_io.string
    end
  end

  class SuperfluidError < Exception
  end

  class Output
    attr_reader :string

    def initialize(initial_indent)
      @string = ''.dup
      @indent_level = initial_indent
      @indent_str = " " * initial_indent * 2
    end

    def <<(line)
      @string << @indent_str << line << "\n"
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
      @output = Output.new(2)
    end

    def ruby
      [
        header,
        @output.string,
        trailer
      ].join("\n")
    end

    def compile(node)
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
        line "break"
      else
        raise SuperfluidError, "Unknown node type #{node.inspect}"
      end
    end

    def header
      <<~RUBY
      module Warning
        def warn(*)
        end
      end

      class GlobalVariableLookup
        def method_missing(method_name, *)
          @context.find_variable(method_name.to_s.delete_prefix("__liquid_"))
        end

        def run(liquid_out, context)
          @context = context
      RUBY
    end

    def trailer
      <<~RUBY
          end
        end
        GlobalVariableLookup.new.method(:run)
      RUBY
    end

    def compile_for(node)
      variable_name = node.variable_name

      collection_name = node.collection_name
      iter_target_expr = case collection_name
                        when Liquid::VariableLookup
                          var(collection_name.name)
                        when Range
                          collection_name
                        when Liquid::RangeLookup
                          start_expr = make_variable_expr(collection_name.start_obj)
                          end_expr = make_variable_expr(collection_name.end_obj)
                          "#{start_expr}..#{end_expr}"
                        else
                          derp "Weird iter!", collection_name
                        end

      line "(#{iter_target_expr}).each do |#{var(variable_name)}|"
        indent { compile(node.for_block) }
      line "end"
    end

    def compile_if(node)
      condition = node.blocks.first
      line "if #{make_condition_expr(condition)}"
        indent { condition.attachment.nodelist.each(&method(:compile)) }
      line "end"
    end

    def compile_capture(node)
      line "#{var(node.to)} = lambda do |; liquid_out|"
      indent do
        line "liquid_out = StringIO.new"
        node.nodelist.each(&method(:compile))
        line "liquid_out.string"
      end
      line "end.call"
    end

    def make_condition_expr(node)
      make_variable_expr(node)
      if node.operator
        left = make_variable_expr(node.left)
        right = make_variable_expr(node.right)
        "#{left} #{node.operator} #{right}"
      else
        make_variable_expr(node.left)
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
        derp "Weird assign", node
      end

      line "#{var(node.to)} = #{from_expr}"
    end

    def make_variable_expr(variable)
      case variable
      when Liquid::Variable
        base_expression = case variable.name
        when Integer
          variable.name
        when String
          variable.name.inspect
        when TrueClass, FalseClass
          variable.name
        when Liquid::VariableLookup
          result = var(variable.name.name)
          variable.name.lookups.each do |lookup|
            result << "[#{make_variable_expr(lookup)}]"
          end
          result
        else
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

          "context.strainer.invoke(#{filter_name.inspect}, #{inner}, #{filter_args.join(", ")})"
        end
      when Liquid::VariableLookup
        var(variable.name)
      else
        variable.inspect
      end
    end

    private

    def line(string)
      output << string
    end

    def echo(string)
      output << "liquid_out.write(#{string})"
    end

    def indent(&block)
      output.indent(&block)
    end

    def var(name)
      "__liquid_#{name}"
    end

    attr_reader :output
  end
end
