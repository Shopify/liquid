module Liquid

  class Literal < Block

    # Class methods

    # Converts a shorthand Liquid literal into its long representation.
    #
    # Currently the Template parser only knows how to handle the long version.
    # So, it always checks if it is in the presence of a literal, in which case it gets converted through this method.
    #
    # Example:
    #   Liquid::Literal "{{{ hello world }}}" #=> "{% literal %} hello world {% endliteral %}"
    def self.from_shorthand(literal)
      literal =~ LiteralShorthand ? "{% literal %}#{$1}{% endliteral %}" : literal
    end

    # Public instance methods

    def parse(tokens) # :nodoc:
      @nodelist ||= []
      @nodelist.clear

      while token = tokens.shift
        if token =~ FullToken && block_delimiter == $1
          end_tag
          return
        else
          @nodelist << token
        end
      end

      # Make sure that its ok to end parsing in the current block.
      # Effectively this method will throw and exception unless the current block is
      # of type Document
      assert_missing_delimitation!
    end # parse

  end

  Template.register_tag('literal', Literal)
end
