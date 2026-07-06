# frozen_string_literal: true

module Liquid
  # Pre-computed 256-entry boolean lookup tables for byte classification.
  # Built once at load time; used as TABLE[byte] — a single array index
  # instead of 3-5 comparison operators per check.
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

    # [a-zA-Z0-9_] — \w equivalent (no hyphen), for tag name scanning
    WORD = Array.new(256, false).tap do |t|
      (97..122).each { |b| t[b] = true }  # a-z
      (65..90).each  { |b| t[b] = true }  # A-Z
      (48..57).each  { |b| t[b] = true }  # 0-9
      t[95] = true # _
    end.freeze

    # [0-9] — ASCII digit
    DIGIT = Array.new(256, false).tap do |t|
      (48..57).each { |b| t[b] = true }
    end.freeze

    # Matches bytes removed by Ruby's String#strip: \x00, \t, \n, \v, \f, \r, space
    WHITESPACE = Array.new(256, false).tap do |t|
      [0, 9, 10, 11, 12, 13, 32].each { |b| t[b] = true }
    end.freeze

    # Byte constants for delimiters and punctuation
    NEWLINE = 10
    DASH    = 45  # '-'
    DOT     = 46  # '.'
    HASH    = 35  # '#'
  end
end
