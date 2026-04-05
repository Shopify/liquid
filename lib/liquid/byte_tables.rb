# frozen_string_literal: true

module Liquid
  # Pre-computed 256-entry boolean lookup tables for byte classification.
  # Built once at load time; used as TABLE[byte] — a single array index
  # instead of 3-5 comparison operators per check.
  #
  # Performance: neutral to slightly faster vs. chained comparisons.
  # Readability: replaces expressions like
  #   (b >= 97 && b <= 122) || (b >= 65 && b <= 90) || b == 95
  # with the intent-revealing
  #   ByteTables::IDENT_START[b]
  module ByteTables
    # [a-zA-Z_] — valid first byte of an identifier
    IDENT_START = Array.new(256, false).tap do |t|
      (97..122).each { |b| t[b] = true }  # a-z
      (65..90).each  { |b| t[b] = true }  # A-Z
      t[95] = true # _
    end.freeze

    # [a-zA-Z0-9_-] — valid continuation byte of an identifier
    IDENT_CONT = Array.new(256, false).tap do |t|
      (97..122).each { |b| t[b] = true }  # a-z
      (65..90).each  { |b| t[b] = true }  # A-Z
      (48..57).each  { |b| t[b] = true }  # 0-9
      t[95] = true                          # _
      t[45] = true                          # -
    end.freeze

    # [0-9] — ASCII digit
    DIGIT = Array.new(256, false).tap do |t|
      (48..57).each { |b| t[b] = true }
    end.freeze

    # [ \t\n\v\f\r] — ASCII whitespace (mirrors Ruby's \s)
    WHITESPACE = Array.new(256, false).tap do |t|
      [32, 9, 10, 11, 12, 13].each { |b| t[b] = true } # space, tab, \n, \v, \f, \r
    end.freeze
  end
end
