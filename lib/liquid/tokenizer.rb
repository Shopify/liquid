module Liquid
  class Tokenizer
    def initialize(source, line_numbers = false)
      @source = source
      @line_numbers = line_numbers
      @tokens = tokenize
    end

    def shift
      @tokens.shift
    end

    private

    def tokenize
      @source = @source.source if @source.respond_to?(:source)
      return [] if @source.to_s.empty?

      tokens = @source.split(TemplateParser)
      tokens = @line_numbers ? calculate_line_numbers(tokens) : tokens

      # removes the rogue empty element at the beginning of the array
      tokens.shift if tokens[0] && tokens[0].empty?

      tokens
    end

    def calculate_line_numbers(tokens)
      current_line = 1
      tokens.map do |token|
        Token.new(token, current_line).tap do
          current_line += token.count("\n")
        end
      end
    end
  end
end
