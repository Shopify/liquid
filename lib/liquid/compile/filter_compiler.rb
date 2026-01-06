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
        'downcase' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).downcase" },
        'upcase' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).upcase" },
        'capitalize' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).capitalize" },
        'strip' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).strip" },
        'lstrip' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).lstrip" },
        'rstrip' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).rstrip" },
        'reverse' => ->(input, _args, _kwargs, _compiler) { "(#{input}.is_a?(Array) ? #{input}.reverse : __to_s__(#{input}).reverse)" },
        'first' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:first) ? #{input}.first : nil)" },
        'last' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:last) ? #{input}.last : nil)" },
        'uniq' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:uniq) ? #{input}.uniq : #{input})" },
        'compact' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:compact) ? #{input}.compact : #{input})" },
        'flatten' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:flatten) ? #{input}.flatten : #{input})" },
        'sort' => ->(input, _args, _kwargs, _compiler) { "(#{input}.respond_to?(:sort) ? #{input}.sort : #{input})" },
        'abs' => ->(input, _args, _kwargs, _compiler) { "__to_number__(#{input}).abs" },
        'ceil' => ->(input, _args, _kwargs, _compiler) { "__to_number__(#{input}).ceil.to_i" },
        'floor' => ->(input, _args, _kwargs, _compiler) { "__to_number__(#{input}).floor.to_i" },
        'escape' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : CGI.escapeHTML(__to_s__(#{input})))" },
        'h' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : CGI.escapeHTML(__to_s__(#{input})))" },
        'url_encode' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : CGI.escape(__to_s__(#{input})))" },
        'url_decode' => ->(input, _args, _kwargs, _compiler) { "(#{input}.nil? ? nil : CGI.unescape(__to_s__(#{input})))" },
        'base64_encode' => ->(input, _args, _kwargs, _compiler) { "Base64.strict_encode64(__to_s__(#{input}))" },
        'base64_decode' => ->(input, _args, _kwargs, _compiler) { "Base64.strict_decode64(__to_s__(#{input}))" },
        'base64_url_safe_encode' => ->(input, _args, _kwargs, _compiler) { "Base64.urlsafe_encode64(__to_s__(#{input}))" },
        'base64_url_safe_decode' => ->(input, _args, _kwargs, _compiler) { "Base64.urlsafe_decode64(__to_s__(#{input}))" },
        'strip_html' => ->(input, _args, _kwargs, _compiler) {
          "__to_s__(#{input}).gsub(%r{<script.*?</script>|<!--.*?-->|<style.*?</style>}m, '').gsub(/<.*?>/m, '')"
        },
        'strip_newlines' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).gsub(/\\r?\\n/, '')" },
        'newline_to_br' => ->(input, _args, _kwargs, _compiler) { "__to_s__(#{input}).gsub(/\\r?\\n/, \"<br />\\n\")" },
      }.freeze

      # Filters with arguments that need special handling
      PARAMETERIZED_FILTERS = {
        'append' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "__to_s__(#{input}) + __to_s__(#{arg})"
        },
        'prepend' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "__to_s__(#{arg}) + __to_s__(#{input})"
        },
        'plus' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(__to_number__(#{input}) + __to_number__(#{arg}))"
        },
        'minus' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(__to_number__(#{input}) - __to_number__(#{arg}))"
        },
        'times' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(__to_number__(#{input}) * __to_number__(#{arg}))"
        },
        'divided_by' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(__to_number__(#{input}) / __to_number__(#{arg}))"
        },
        'modulo' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "(__to_number__(#{input}) % __to_number__(#{arg}))"
        },
        'round' => ->(input, args, _kwargs, compiler) {
          if args.empty?
            "__to_number__(#{input}).round.to_i"
          else
            arg = compile_arg(args[0], compiler)
            "__to_number__(#{input}).round(__to_number__(#{arg}))"
          end
        },
        'at_least' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "[__to_number__(#{input}), __to_number__(#{arg})].max"
        },
        'at_most' => ->(input, args, _kwargs, compiler) {
          arg = compile_arg(args[0], compiler)
          "[__to_number__(#{input}), __to_number__(#{arg})].min"
        },
        'default' => ->(input, args, kwargs, compiler) {
          default_val = args.empty? ? "''" : compile_arg(args[0], compiler)
          allow_false = kwargs && kwargs['allow_false'] ? compile_arg(kwargs['allow_false'], compiler) : 'false'
          "(if #{allow_false} then (#{input}.nil? || (#{input}.respond_to?(:empty?) && #{input}.empty?)) else (!__truthy__(#{input}) || (#{input}.respond_to?(:empty?) && #{input}.empty?)) end) ? #{default_val} : #{input}"
        },
        'split' => ->(input, args, _kwargs, compiler) {
          pattern = args.empty? ? "' '" : compile_arg(args[0], compiler)
          "__to_s__(#{input}).split(__to_s__(#{pattern}))"
        },
        'join' => ->(input, args, _kwargs, compiler) {
          glue = args.empty? ? "' '" : compile_arg(args[0], compiler)
          "(#{input}.is_a?(Array) ? #{input}.map { |i| __to_s__(i) }.join(__to_s__(#{glue})) : __to_s__(#{input}))"
        },
        'replace' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          replacement = args.length > 1 ? compile_arg(args[1], compiler) : "''"
          "__to_s__(#{input}).gsub(__to_s__(#{string}), __to_s__(#{replacement}))"
        },
        'replace_first' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          replacement = args.length > 1 ? compile_arg(args[1], compiler) : "''"
          "__to_s__(#{input}).sub(__to_s__(#{string}), __to_s__(#{replacement}))"
        },
        'remove' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          "__to_s__(#{input}).gsub(__to_s__(#{string}), '')"
        },
        'remove_first' => ->(input, args, _kwargs, compiler) {
          string = compile_arg(args[0], compiler)
          "__to_s__(#{input}).sub(__to_s__(#{string}), '')"
        },
        'truncate' => ->(input, args, _kwargs, compiler) {
          length = args.empty? ? "50" : compile_arg(args[0], compiler)
          ellipsis = args.length > 1 ? compile_arg(args[1], compiler) : "'...'"
          var = compiler.generate_var_name("trunc")
          "(lambda { |#{var}_input, #{var}_len, #{var}_ell| #{var}_str = __to_s__(#{var}_input); #{var}_ell_str = __to_s__(#{var}_ell); #{var}_l = [#{var}_len.to_i - #{var}_ell_str.length, 0].max; #{var}_str.length > #{var}_len.to_i ? #{var}_str[0, #{var}_l] + #{var}_ell_str : #{var}_str }).call(#{input}, #{length}, #{ellipsis})"
        },
        'truncatewords' => ->(input, args, _kwargs, compiler) {
          words = args.empty? ? "15" : compile_arg(args[0], compiler)
          ellipsis = args.length > 1 ? compile_arg(args[1], compiler) : "'...'"
          "(lambda { |input, num_words, ell| words = __to_s__(input).split(' ', [num_words.to_i, 1].max + 1); words.length > [num_words.to_i, 1].max ? words[0, [num_words.to_i, 1].max].join(' ') + __to_s__(ell) : input.to_s }).call(#{input}, #{words}, #{ellipsis})"
        },
        'slice' => ->(input, args, _kwargs, compiler) {
          offset = compile_arg(args[0], compiler)
          length = args.length > 1 ? compile_arg(args[1], compiler) : "1"
          "(#{input}.is_a?(Array) ? (#{input}.slice(__to_integer__(#{offset}), __to_integer__(#{length})) || []) : (__to_s__(#{input}).slice(__to_integer__(#{offset}), __to_integer__(#{length})) || ''))"
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
            "(#{input}.is_a?(Array) ? #{input}.select { |item| item.respond_to?(:[]) && __truthy__(item[#{property}]) } : [])"
          end
        },
        'reject' => ->(input, args, _kwargs, compiler) {
          property = compile_arg(args[0], compiler)
          if args.length > 1
            target = compile_arg(args[1], compiler)
            "(#{input}.is_a?(Array) ? #{input}.reject { |item| item.respond_to?(:[]) && item[#{property}] == #{target} } : [])"
          else
            "(#{input}.is_a?(Array) ? #{input}.reject { |item| item.respond_to?(:[]) && __truthy__(item[#{property}]) } : [])"
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
          # This is a simplified version - full date parsing is complex
          "(lambda { |input, fmt| return input if fmt.to_s.empty?; d = case input; when Time, Date, DateTime then input; when 'now', 'today' then Time.now; when /\\A\\d+\\z/, Integer then Time.at(input.to_i); when String then (Time.parse(input) rescue input); else input; end; d.respond_to?(:strftime) ? d.strftime(fmt.to_s) : input }.call(#{input}, #{format}))"
        },
        'escape_once' => ->(input, _args, _kwargs, _compiler) {
          "__to_s__(#{input}).gsub(/[\"><']|&(?!([a-zA-Z]+|(#\\d+));)/) { |c| {'&'=>'&amp;', '>'=>'&gt;', '<'=>'&lt;', '\"'=>'&quot;', \"'\"=>'&#39;'}[c] || c }"
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
      # Uses __call_filter__ helper which must be provided by the runtime
      def self.compile_generic_filter(input, name, args, kwargs, compiler)
        # Mark that we're using external filters
        compiler.register_external_filter

        compiled_args = args.map { |arg| compile_arg(arg, compiler) }

        if kwargs && !kwargs.empty?
          kwargs_hash = kwargs.map { |k, v| "#{k.inspect} => #{compile_arg(v, compiler)}" }.join(", ")
          compiled_args << "{ #{kwargs_hash} }"
        end

        args_str = compiled_args.empty? ? "[]" : "[#{compiled_args.join(', ')}]"

        # Call through the filter helper which delegates to registered filters
        "__call_filter__.call(#{name.inspect}, #{input}, #{args_str})"
      end

      # Compile a filter argument
      def self.compile_arg(arg, compiler)
        ExpressionCompiler.compile(arg, compiler)
      end
    end
  end
end
