# frozen_string_literal: true

module Liquid
  class VariableLookup
    COMMAND_METHODS = ['size', 'first', 'last'].freeze

    attr_reader :name, :lookups

    def self.parse(markup)
      new(markup)
    end

    LITERALS = Expression::LITERALS.keys.freeze
    private_constant :LITERALS

    def self.lax_migrate(markup)
      new_markup = nil
      last_match = nil
      first_match = nil
      markup.scan(VariableParser) do |lookup|
        last_match = Regexp.last_match
        first_match ||= last_match
        new_markup ||= +""
        if lookup&.start_with?('[') && lookup&.end_with?(']')
          new_markup << "[" << Expression.lax_migrate(lookup[1..-2]) << "]"
        elsif !lookup.match?(/\A#{Liquid::Lexer::IDENTIFIER}\z/)
          # quote non-strictly valid identifiers
          new_markup << "['" << lookup << "']"
        else
          new_markup << "." unless new_markup.empty?
          new_markup << lookup
        end
      end

      case new_markup
      when nil
        # `markup.scan(VariableParser)` may skip over all characters
        new_markup ||= " nil "
      when Expression::INTEGERS_REGEX, Expression::RANGES_REGEX, Expression::FLOATS_REGEX, *LITERALS
        # Quote variable lookups that match literals after characters are skipped by regex scanning
        new_markup = "['#{new_markup}']"
      else
        new_markup.prepend(" ") if first_match.begin(0) > 0
        new_markup << ' ' if last_match.end(0) < markup.length
      end

      new_markup
    end

    def initialize(markup)
      lookups = markup.scan(VariableParser)

      name = lookups.shift
      if name&.start_with?('[') && name&.end_with?(']')
        name = Expression.parse(name[1..-2])
      end
      @name = name

      @lookups       = lookups
      @command_flags = 0

      @lookups.each_index do |i|
        lookup = lookups[i]
        if lookup&.start_with?('[') && lookup&.end_with?(']')
          lookups[i] = Expression.parse(lookup[1..-2])
        elsif COMMAND_METHODS.include?(lookup)
          @command_flags |= 1 << i
        end
      end
    end

    def lookup_command?(lookup_index)
      @command_flags & (1 << lookup_index) != 0
    end

    def evaluate(context)
      name   = context.evaluate(@name)
      object = context.find_variable(name)

      @lookups.each_index do |i|
        key = context.evaluate(@lookups[i])

        # Cast "key" to its liquid value to enable it to act as a primitive value
        key = Liquid::Utils.to_liquid_value(key)

        # If object is a hash- or array-like object we look for the
        # presence of the key and if its available we return it
        if object.respond_to?(:[]) &&
            ((object.respond_to?(:key?) && object.key?(key)) ||
             (object.respond_to?(:fetch) && key.is_a?(Integer)))

          # if its a proc we will replace the entry with the proc
          res    = context.lookup_and_evaluate(object, key)
          object = res.to_liquid

          # Some special cases. If the part wasn't in square brackets and
          # no key with the same name was found we interpret following calls
          # as commands and call them on the current object
        elsif lookup_command?(i) && object.respond_to?(key)
          object = object.send(key).to_liquid

          # No key was present with the desired value and it wasn't one of the directly supported
          # keywords either. The only thing we got left is to return nil or
          # raise an exception if `strict_variables` option is set to true
        else
          return nil unless context.strict_variables
          raise Liquid::UndefinedVariable, "undefined variable #{key}"
        end

        # If we are dealing with a drop here we have to
        object.context = context if object.respond_to?(:context=)
      end

      object
    end

    def ==(other)
      self.class == other.class && state == other.state
    end

    protected

    def state
      [@name, @lookups, @command_flags]
    end

    class ParseTreeVisitor < Liquid::ParseTreeVisitor
      def children
        @node.lookups
      end
    end
  end
end
