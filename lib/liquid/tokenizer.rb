# frozen_string_literal: true

module Liquid
  class Tokenizer
    attr_reader :line_number, :for_liquid_tag

    def initialize(source, line_numbers = false, line_number: nil, for_liquid_tag: false)
      @source = source
      @line_number = line_number || (line_numbers ? 1 : nil)
      @for_liquid_tag = for_liquid_tag
      @tokens = tokenize
    end

    def shift
      (token = @tokens.shift) || return

      if @line_number
        @line_number += @for_liquid_tag ? 1 : token.count("\n")
      end

      token
    end

    private

    def tokenize
      return [] if @source.to_s.empty?

      return @source.split("\n") if @for_liquid_tag

      tokens = tokenize_new(@source)
      # tokens = @source.split(TemplateParser)

      # removes the rogue empty element at the beginning of the array
      tokens.shift if tokens[0]&.empty?

      tokens
    end

    T_TAG_OPEN = "{%"
    T_VAR_OPEN = "{{"
    T_SIN_QUOT = "'"
    T_DOU_QUOT = '"'
    T_TAG_CLOS = "%}"
    T_VAR_CLOS = "}}"
    T_VAR_CLO2 = "}"

    S_NIL = 0
    S_TAG = 1
    S_VAR = 2
    S_TAG_SIN = 3
    S_TAG_DOU = 4
    S_VAR_SIN = 5
    S_VAR_DOU = 6

    def tokenize_new(source)
      output = []
      s = S_NIL
      current = +""
      source.split(/({%|{{|"|'|}}|%}|})/om).each do |t|
        if t == T_TAG_OPEN && s <= S_VAR
          s = S_TAG
          output << current
          current = t
        elsif t == T_VAR_OPEN && s <= S_VAR
          s = S_VAR
          output << current
          current = t
        elsif t == T_VAR_OPEN && s == S_TAG
          s = S_VAR
          current += t
        elsif t == T_SIN_QUOT && s == S_TAG
          s = S_TAG_SIN
          current += t
        elsif t == T_SIN_QUOT && s == S_TAG_SIN
          s = S_TAG
          current += t
        elsif t == T_DOU_QUOT && s == S_TAG
          s = S_TAG_DOU
          current += t
        elsif t == T_DOU_QUOT && s == S_TAG_DOU
          s = S_TAG
          current += t
        elsif t == T_SIN_QUOT && s == S_VAR
          s = S_VAR_SIN
          current += t
        elsif t == T_SIN_QUOT && s == S_VAR_SIN
          s = S_VAR
          current += t
        elsif t == T_DOU_QUOT && s == S_VAR
          s = S_VAR_DOU
          current += t
        elsif t == T_DOU_QUOT && s == S_VAR_DOU
          s = S_VAR
          current += t
        elsif t == T_TAG_CLOS && s == S_TAG
          s = S_NIL
          current += t
          output << current
          current = +""
        elsif (t == T_VAR_CLOS || t == T_VAR_CLO2) && s == S_VAR
          s = S_NIL
          current += t
          output << current
          current = +""
        else
          current += t
        end
      end
      output << current unless current == ""
      output
    end
  end
end
