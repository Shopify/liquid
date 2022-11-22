# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category iteration
  # @liquid_name cycle
  # @liquid_summary
  #   Loops through a group of strings and outputs them one at a time for each iteration of a [`for` loop](/api/liquid/tags/for).
  # @liquid_description
  #   The `cycle` tag must be used inside a `for` loop.
  #
  #   > Tip:
  #   > Use the `cycle` tag to output text in a predictable pattern. For example, to apply odd/even classes to rows in a table.
  # @liquid_syntax
  #   {% cycle string, string, ... %}
  class Cycle < Tag
    SimpleSyntax = /\A#{QuotedFragment}+/o
    NamedSyntax  = /\A(#{QuotedFragment})\s*\:\s*(.*)/om

    def self.migrate(tag_name, markup, tokenizer, parse_context)
      new_markup = case markup
      when NamedSyntax
        match = Regexp.last_match

        new_name_syntax = Expression.lax_migrate(match[1])
        new_variables_markup = migrate_variables_from_string(match[2])

        Utils.match_captures_replace(match, 1 => new_name_syntax, 2 => new_variables_markup)
      when SimpleSyntax
        match = Regexp.last_match
        migrate_variables_from_string(markup)
      else
        raise SyntaxError
      end

      # replace scanned over characters with a space to ensure there is a space
      # to separate the tag name and the variable name
      new_markup.prepend(" ") if match.begin(0) > 0

      new_markup
    end

    def self.migrate_variables_from_string(markup)
      markup.split(',').collect do |var|
        match = var.match(/\s*(#{QuotedFragment})\s*/o)
        if match
          Utils.match_captures_replace(match, 1 => Expression.lax_migrate(match[1]))
        end
      end.compact.join(",")
    end

    attr_reader :variables

    # @api private
    attr_reader :name

    def initialize(tag_name, markup, options)
      super
      case markup
      when NamedSyntax
        @variables = variables_from_string(Regexp.last_match(2))
        @name      = parse_expression(Regexp.last_match(1))
      when SimpleSyntax
        @variables = variables_from_string(markup)
        @name      = @variables.to_s
      else
        raise SyntaxError, options[:locale].t("errors.syntax.cycle")
      end
    end

    def render_to_output_buffer(context, output)
      context.registers[:cycle] ||= {}

      key       = context.evaluate(@name)
      iteration = context.registers[:cycle][key].to_i

      val = context.evaluate(@variables[iteration])

      if val.is_a?(Array)
        val = val.join
      elsif !val.is_a?(String)
        val = val.to_s
      end

      output << val

      iteration += 1
      iteration = 0 if iteration >= @variables.size

      context.registers[:cycle][key] = iteration
      output
    end

    private

    def variables_from_string(markup)
      markup.split(',').collect do |var|
        var =~ /\s*(#{QuotedFragment})\s*/o
        Regexp.last_match(1) ? parse_expression(Regexp.last_match(1)) : nil
      end.compact
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        Array(@node.variables)
      end
    end
  end

  Template.register_tag('cycle', Cycle)
end
