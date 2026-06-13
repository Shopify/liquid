# frozen_string_literal: true

module Liquid
  module Compile
    # SourceMapper provides utilities for mapping errors in compiled Ruby code
    # back to the original Liquid source.
    #
    # When code is compiled with debug: true, comments are embedded that contain
    # source location information. This class can parse those comments and
    # help trace errors back to the original Liquid template.
    #
    # ## Usage
    #
    #   template = Liquid::Template.parse(source, line_numbers: true)
    #   ruby_code = template.compile_to_ruby(debug: true)
    #   render_proc = eval(ruby_code)
    #
    #   begin
    #     result = render_proc.call(assigns)
    #   rescue => e
    #     location = SourceMapper.find_source_location(ruby_code, e)
    #     puts "Error at Liquid line #{location[:liquid_line]}: #{location[:source]}"
    #   end
    #
    class SourceMapper
      # Pattern to match LIQUID debug comments
      LIQUID_COMMENT_PATTERN = /^(\s*)# LIQUID(?: \| L(\d+))?(?: \| ([^|]+))?(?: \| (.+))?$/

      # Parse compiled Ruby code and extract source mapping entries
      # @param ruby_code [String] The compiled Ruby code with debug comments
      # @return [Array<Hash>] Array of source mapping entries
      def self.parse(ruby_code)
        entries = []
        ruby_line = 0

        ruby_code.each_line do |line|
          ruby_line += 1

          if line =~ LIQUID_COMMENT_PATTERN
            entries << {
              ruby_line: ruby_line,
              liquid_line: $2&.to_i,
              type: $3&.strip,
              source: parse_source_string($4),
            }
          end
        end

        entries
      end

      # Find the source location for an error based on Ruby line number
      # @param ruby_code [String] The compiled Ruby code
      # @param error [Exception] The exception that was raised
      # @return [Hash, nil] Source location info or nil if not found
      def self.find_source_location(ruby_code, error)
        # Extract the line number from the error
        ruby_line = extract_error_line(error)
        return nil unless ruby_line

        find_source_for_ruby_line(ruby_code, ruby_line)
      end

      # Find the source location for a specific Ruby line number
      # @param ruby_code [String] The compiled Ruby code
      # @param target_line [Integer] The Ruby line number
      # @return [Hash, nil] Source location info or nil if not found
      def self.find_source_for_ruby_line(ruby_code, target_line)
        entries = parse(ruby_code)

        # Find the closest LIQUID comment at or before the target line
        closest = nil
        entries.each do |entry|
          break if entry[:ruby_line] > target_line
          closest = entry
        end

        closest
      end

      # Format an error message with source location info
      # @param ruby_code [String] The compiled Ruby code
      # @param error [Exception] The exception
      # @return [String] Formatted error message
      def self.format_error(ruby_code, error)
        location = find_source_location(ruby_code, error)

        message = "#{error.class}: #{error.message}"

        if location
          liquid_line = location[:liquid_line] ? "line #{location[:liquid_line]}" : "unknown line"
          source = location[:source] || location[:type] || "unknown"
          message += "\n  in Liquid template at #{liquid_line}"
          message += "\n  source: #{source}" if location[:source]
        end

        message
      end

      private

      def self.extract_error_line(error)
        # Look for (eval):N in backtrace
        error.backtrace&.each do |frame|
          if frame =~ /\(eval.*?\):(\d+)/
            return $1.to_i
          end
        end
        nil
      end

      def self.parse_source_string(str)
        return nil unless str

        # Remove surrounding quotes if present
        str = str.strip
        if str.start_with?('"') && str.end_with?('"')
          # Unescape the string
          begin
            eval(str)
          rescue
            str[1..-2]
          end
        else
          str
        end
      end
    end
  end
end
