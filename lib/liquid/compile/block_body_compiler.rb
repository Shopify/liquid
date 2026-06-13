# frozen_string_literal: true

module Liquid
  module Compile
    # BlockBodyCompiler compiles a BlockBody (a list of nodes) to Ruby code.
    #
    # A BlockBody contains:
    # - String literals (text to output)
    # - Variable expressions ({{ ... }})
    # - Tags ({% ... %})
    class BlockBodyCompiler
      # Compile a BlockBody to Ruby code
      # @param body [Liquid::BlockBody] The block body
      # @param compiler [RubyCompiler] The main compiler instance
      # @param code [CodeGenerator] The code generator
      def self.compile(body, compiler, code)
        return if body.nil?

        nodelist = body.nodelist
        return if nodelist.nil? || nodelist.empty?

        nodelist.each do |node|
          compile_node(node, compiler, code)
        end
      end

      # Compile a single node
      def self.compile_node(node, compiler, code)
        case node
        when String
          compile_string(node, code)
        when Variable
          VariableCompiler.compile(node, compiler, code)
        when Tag
          compiler.send(:compile_tag, node, code)
        else
          raise CompileError, "Unknown node type in BlockBody: #{node.class}"
        end
      end

      private

      def self.compile_string(str, code)
        return if str.empty?
        code.line "__output__ << #{str.inspect}"
      end
    end
  end
end
