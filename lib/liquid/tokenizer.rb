module Liquid
  class Tokenizer
    VariableIncompleteEnd = /\}\}?/
    AnyStartingTag        = /\{\{|\{\%/
    PartialTemplateParser = /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/om
    TemplateParser        = /(#{PartialTemplateParser}|#{AnyStartingTag})/om

    def initialize(source)
      @tokens = source.split(TemplateParser)

      # removes the rogue empty element at the beginning of the array
      @tokens.shift if @tokens[0] && @tokens[0].empty?
    end

    def next
      @tokens.shift
    end
    alias_method :shift, :next
  end
end
