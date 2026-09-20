# frozen_string_literal: true

module Liquid
  module Compile
    # CodeGenerator provides a clean interface for building Ruby code strings
    # with proper indentation and formatting.
    class CodeGenerator
      INDENT_SIZE = 2

      def initialize
        @lines = []
        @indent_level = 0
      end

      # Add a line of code at the current indentation level
      # @param text [String] The code to add
      def line(text)
        @lines << ("  " * @indent_level) + text
      end

      # Add a blank line
      def blank_line
        @lines << ""
      end

      # Add multiple lines (useful for multi-line strings)
      # @param text [String] Multi-line string to add
      def lines(text)
        text.each_line do |l|
          line(l.chomp)
        end
      end

      # Increase indentation for a block
      def indent
        @indent_level += 1
        yield
        @indent_level -= 1
      end

      # Get the current indentation string
      def current_indent
        "  " * @indent_level
      end

      # Add raw code without indentation adjustment
      def raw(text)
        @lines << text
      end

      # Convert to final Ruby code string
      def to_s
        @lines.join("\n")
      end

      # Generate an inline expression (doesn't add to lines, returns string)
      # @param expr [String] The expression
      # @return [String] The expression wrapped appropriately
      def self.inline(expr)
        expr
      end

      # Generate a string literal
      # @param str [String] The string to escape
      # @return [String] Ruby string literal
      def self.string_literal(str)
        str.inspect
      end

      # Generate a safe variable name from a Liquid variable name
      # @param name [String] The Liquid variable name
      # @return [String] A safe Ruby variable name
      def self.safe_var_name(name)
        # Replace invalid characters with underscores
        safe = name.to_s.gsub(/[^a-zA-Z0-9_]/, '_')
        # Ensure it starts with a letter or underscore
        safe = "_#{safe}" if safe =~ /\A\d/
        safe
      end
    end
  end
end
