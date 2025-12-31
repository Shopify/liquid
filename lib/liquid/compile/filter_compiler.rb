# frozen_string_literal: true

module Liquid
  module Compile
    # FilterCompiler compiles Liquid filter chains to Ruby code.
    #
    # Filters are applied in sequence: {{ value | filter1: arg1 | filter2: arg2 }}
    # becomes a chain of method calls on the value.
    class FilterCompiler
      # Standard filters that map directly to Ruby methods or simple expressions
      SIMPLE_FILTERS = {
        'size' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:size) ? #{input}.size : 0)" },
        'downcase' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).downcase" },
        'upcase' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).upcase" },
        'capitalize' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).capitalize" },
        'strip' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).strip" },
        'lstrip' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).lstrip" },
        'rstrip' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).rstrip" },
        'reverse' => ->(input, _args, _kwargs, _compiler) { "(#{input}.is_a?(Array) ? #{input}.reverse : LR.to_s(#{input}).reverse)" },
        'first' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:first) ? #{input}.first : nil)" },
        'last' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:last) ? #{input}.last : nil)" },
        'uniq' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:uniq) ? #{input}.uniq : #{input})" },
        'compact' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:compact) ? #{input}.compact : #{input})" },
        'flatten' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:flatten) ? #{input}.flatten : #{input})" },
        'sort' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:sort) ? #{input}.sort : #{input})" },
        'abs' => ->(input, _args, _kwargs, _compiler) { "LR.to_number(#{input}).abs" },
        'ceil' => ->(input, _args, _kwargs, _compiler) { "LR.to_number(#{input}).ceil.to_i" },
        'floor' => ->(input, _args, _kwargs, _compiler) { "LR.to_number(#{input}).floor.to_i" },
        'escape' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : LR.escape_html(#{input}))" },
        'h' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : LR.escape_html(#{input}))" },
        'url_encode' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : LR.url_encode(#{input}))" },
        'url_decode' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : LR.url_decode(#{input}))" },
        'base64_encode' => ->(input, _args, _kwargs, _compiler) { "LR.base64_encode(#{input})" },
        'base64_decode' => ->(input, _args, _kwargs, _compiler) { "LR.base64_decode(#{input})" },
        'base64_url_safe_encode' => ->(input, _args, _kwargs, _compiler) { "LR.base64_url_safe_encode(#{input})" },
        'base64_url_safe_decode' => ->(input, _args, _kwargs, _compiler) { "LR.base64_url_safe_decode(#{input})" },
        'strip_html' => ->(input, _args, _kwargs, _compiler) { "LR.strip_html(#{input})" },
        'strip_newlines' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).gsub(/\\r?\\n/, '')" },
        'newline_to_br' => ->(input, _args, _kwargs, _compiler) { "LR.to_s(#{input}).gsub(/\\r?\\n/, \"<br />\\n\")" },
      }.freeze

      # Filters with arguments that need special handling
      # All use LR.method() calls to pre-loaded runtime
      PARAMETERIZED_FILTERS = {
        'append' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "LR.to_s(#{input}) + LR.to_s(#{arg})"
        },
        'prepend' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "LR.to_s(#{arg}) + LR.to_s(#{input})"
        },
        'plus' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(LR.to_number(#{input}) + LR.to_number(#{arg}))"
        },
        'minus' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(LR.to_number(#{input}) - LR.to_number(#{arg}))"
        },
        'times' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(LR.to_number(#{input}) * LR.to_number(#{arg}))"
        },
        'divided_by' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(LR.to_number(#{input}) / LR.to_number(#{arg}))"
        },
        'modulo' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(LR.to_number(#{input}) % LR.to_number(#{arg}))"
        },
        'round' => ->(input, args, _kwargs, compiler) {
          if args.empty?
            "LR.to_number(#{input}).round.to_i"
          else
            arg = compile_arg(args[0], compiler)
            "LR.to_number(#{input}).round(LR.to_number(#{arg}))"
          end
        },
        'at_least' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "[LR.to_number(#{input}), LR.to_number(#{arg})].max"
        },
        'at_most' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "[LR.to_number(#{input}), LR.to_number(#{arg})].min"
        },
        'default' => ->(input, args, kwargs, compiler) {
          default_val = args.empty? ? "''" : compile_arg(args[0], compiler)
          allow_false = kwargs && kwargs['allow_false'] ? "allow_false: #{compile_arg(kwargs['allow_false'], compiler)}" : ''
          "LR.default(#{input}, #{default_val}#{allow_false.empty? ? '' : ', ' + allow_false})"
        },
        'split' => ->(input, args, _kwargs, compiler) {
          pattern = args.empty? ? "' '" : compile_arg(args[0], compiler)
          "LR.to_s(#{input}).split(LR.to_s(#{pattern}))"
        },
        'join' => ->(input, args, _kwargs, compiler) {
          glue = args.empty? ? "' '" : compile_arg(args[0], compiler)
          "(#{input}.is_a?(Array) ? #{input}.map { |i| LR.to_s(i) }.join(LR.to_s(#{glue})) : LR.to_s(#{input}))"
        },
        'replace' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          replacement = args.length > 1 ? compile_arg(args[1], compiler) : "''"
          "LR.to_s(#{input}).gsub(LR.to_s(#{string}), LR.to_s(#{replacement}))"
        },
        'replace_first' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          replacement = args.length > 1 ? compile_arg(args[1], compiler) : "''"
          "LR.to_s(#{input}).sub(LR.to_s(#{string}), LR.to_s(#{replacement}))"
        },
        'remove' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          "LR.to_s(#{input}).gsub(LR.to_s(#{string}), '')"
        },
        'remove_first' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          "LR.to_s(#{input}).sub(LR.to_s(#{string}), '')"
        },
        'truncate' => ->(input, args, _kwargs, compiler) {
          length = args.empty? ? "50" : compile_arg(args[0], compiler)
          ellipsis = args.length > 1 ? compile_arg(args[1], compiler) : "'...'"
          "LR.truncate(#{input}, #{length}, #{ellipsis})"
        },
        'truncatewords' => ->(input, args, _kwargs, compiler) {
          words = args.empty? ? "15" : compile_arg(args[0], compiler)
          ellipsis = args.length > 1 ? compile_arg(args[1], compiler) : "'...'"
          "LR.truncatewords(#{input}, #{words}, #{ellipsis})"
        },
        'slice' => ->(input, args, _kwargs, compiler) {
          offset = compile_arg(args[0], compiler)
          length = args.length > 1 ? compile_arg(args[1], compiler) : "1"
          "LR.slice(#{input}, #{offset}, #{length})"
        },
        'map' => ->(input, args, _kwargs, compiler) {
          property = compile_arg(args[0], compiler)
          "(#{input}.is_a?(Array) ? #{input}.map { |item| item.respond_to?(:[]) ? item[#{property}] : nil } : [])"
        },
        'where' => ->(input, args, _kwargs, compiler) {
          property = compile_arg(args[0], compiler)
          if args.length > 1
            target = compile_arg(args[1], compiler)
            "(#{input}.is_a?(Array) ? #{input}.select { |item| item.respond_to?(:[]) && item[#{property}] == #{target} } : [])"
          else
            "(#{input}.is_a?(Array) ? #{input}.select { |item| item.respond_to?(:[]) && LR.truthy?(item[#{property}]) } : [])"
          end
        },
        'reject' => ->(input, args, _kwargs, compiler) {
          property = compile_arg(args[0], compiler)
          if args.length > 1
            target = compile_arg(args[1], compiler)
            "(#{input}.is_a?(Array) ? #{input}.reject { |item| item.respond_to?(:[]) && item[#{property}] == #{target} } : [])"
          else
            "(#{input}.is_a?(Array) ? #{input}.reject { |item| item.respond_to?(:[]) && LR.truthy?(item[#{property}]) } : [])"
          end
        },
        'concat' => ->(input, args, _kwargs, compiler) {
          arr = compile_arg(args[0], compiler)
          "(#{input}.is_a?(Array) ? #{input} + (#{arr}.respond_to?(:to_ary) ? #{arr}.to_ary : []) : [])"
        },
        'sort_natural' => ->(input, args, _kwargs, compiler) {
          if args.empty?
            "(#{input}.is_a?(Array) ? #{input}.sort_by { |a| a.to_s.downcase } : #{input})"
          else
            property = compile_arg(args[0], compiler)
            "(#{input}.is_a?(Array) ? #{input}.sort_by { |a| a.respond_to?(:[]) ? a[#{property}].to_s.downcase : '' } : #{input})"
          end
        },
        'date' => ->(input, args, _kwargs, compiler) {
          format = compile_arg(args[0], compiler)
          "LR.date(#{input}, #{format})"
        },
        'escape_once' => ->(input, _args, _kwargs, _compiler) {
          "LR.escape_once(#{input})"
        },
      }.freeze

      # Compile a filter chain
      # @param input_expr [String] Ruby expression for the input value
      # @param filters [Array] Array of filter definitions [name, args, kwargs]
      # @param compiler [RubyCompiler] The main compiler instance
      # @return [String] Ruby code that applies all filters
      def self.compile(input_expr, filters, compiler)
        result = input_expr

        filters.each do |filter_name, filter_args, filter_kwargs|
          result = compile_filter(result, filter_name, filter_args || [], filter_kwargs, compiler)
        end

        result
      end

      # Compile a single filter application
      def self.compile_filter(input, name, args, kwargs, compiler)
        if SIMPLE_FILTERS.key?(name)
          SIMPLE_FILTERS[name].call(input, args, kwargs, compiler)
        elsif PARAMETERIZED_FILTERS.key?(name)
          PARAMETERIZED_FILTERS[name].call(input, args, kwargs, compiler)
        else
          # Fall back to a generic filter call
          compile_generic_filter(input, name, args, kwargs, compiler)
        end
      end

      # Compile a filter that's not built-in
      # Yields [:filter, name, input, args] to the external handler
      def self.compile_generic_filter(input, name, args, kwargs, compiler)
        # Mark that we're using external filters
        compiler.register_external_filter

        compiled_args = args.map { |arg| compile_arg(arg, compiler) }

        if kwargs && !kwargs.empty?
          kwargs_hash = kwargs.map { |k, v| "#{k.inspect} => #{compile_arg(v, compiler)}" }.join(", ")
          compiled_args << "{ #{kwargs_hash} }"
        end

        args_str = compiled_args.empty? ? "[]" : "[#{compiled_args.join(', ')}]"

        # Yield to the external handler
        "__external__.call(:filter, #{name.inspect}, #{input}, #{args_str})"
      end

      # Compile a filter argument
      def self.compile_arg(arg, compiler)
        ExpressionCompiler.compile(arg, compiler)
      end
    end
  end
end
