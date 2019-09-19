# frozen_string_literal: true

module Liquid
  FilterSeparator            = FILTER_SEPARATOR
  ArgumentSeparator          = ARGUMENT_SEPARATOR
  FilterArgumentSeparator    = FILTER_ARGUMENT_SEPARATOR
  VariableAttributeSeparator = VARIABLE_ATTRIBUTE_SEPARATOR
  WhitespaceControl          = WHITESPACE_CONTROL
  TagStart                   = TAG_START
  TagEnd                     = TAG_END
  VariableSignature          = VARIABLE_SIGNATURE
  VariableSegment            = VARIABLE_SEGMENT
  VariableStart              = VARIABLE_START
  VariableEnd                = VARIABLE_END
  VariableIncompleteEnd      = VARIABLE_INCOMPLETE_END
  QuotedString               = QUOTED_STRING
  QuotedFragment             = QUOTED_FRAGMENT
  TagAttributes              = TAG_ATTRIBUTES
  AnyStartingTag             = ANY_STARTING_TAG
  PartialTemplateParser      = PARTIAL_TEMPLATE_PARSER
  TemplateParser             = TEMPLATE_PARSER
  VariableParser             = VARIABLE_PARSER

  class BlockBody
    FullToken           = FULL_TOKEN
    ContentOfVariable   = CONTENT_OF_VARIABLE
    WhitespaceOrNothing = WHITESPACE_OR_NOTHING
    TAGSTART            = TAG_START_STRING
    VARSTART            = VAR_START_STRING
  end

  class Assign < Tag
    Syntax = SYNTAX
  end

  class Capture < Block
    Syntax = SYNTAX
  end

  class Case < Block
    Syntax     = SYNTAX
    WhenSyntax = WHEN_SYNTAX
  end

  class Cycle < Tag
    SimpleSyntax = SIMPLE_SYNTAX
    NamedSyntax  = NAMED_SYNTAX
  end

  class For < Block
    Syntax = SYNTAX
  end

  class If < Block
    Syntax                  = SYNTAX
    ExpressionsAndOperators = EXPRESSIONS_AND_OPERATORS
  end

  class Include < Tag
    Syntax = SYNTAX
  end

  class Raw < Block
    Syntax                   = SYNTAX
    FullTokenPossiblyInvalid = FULL_TOKEN_POSSIBLY_INVALID
  end

  class TableRow < Block
    Syntax = SYNTAX
  end

  class Variable
    FilterMarkupRegex        = FILTER_MARKUP_REGEX
    FilterParser             = FILTER_PARSER
    FilterArgsRegex          = FILTER_ARGS_REGEX
    JustTagAttributes        = JUST_TAG_ATTRIBUTES
    MarkupWithQuotedFragment = MARKUP_WITH_QUOTED_FRAGMENT
  end
end
