# frozen_string_literal: true

# Copyright (c) 2005 Tobias Luetke
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require "strscan"

module Liquid
  FilterSeparator             = /\|/
  ArgumentSeparator           = ','
  FilterArgumentSeparator     = ':'
  VariableAttributeSeparator  = '.'
  WhitespaceControl           = '-'
  TagStart                    = /\{\%/
  TagEnd                      = /\%\}/
  TagName                     = /#|\w+/
  VariableSignature           = /\(?[\w\-\.\[\]]\)?/
  VariableSegment             = /[\w\-]/
  VariableStart               = /\{\{/
  VariableEnd                 = /\}\}/
  VariableIncompleteEnd       = /\}\}?/
  QuotedString                = /"[^"]*"|'[^']*'/
  QuotedFragment              = /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/o
  TagAttributes               = /(\w[\w-]*)\s*\:\s*(#{QuotedFragment})/o
  AnyStartingTag              = /#{TagStart}|#{VariableStart}/o
  PartialTemplateParser       = /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/om
  TemplateParser              = /(#{PartialTemplateParser}|#{AnyStartingTag})/om
  VariableParser              = /\[(?>[^\[\]]+|\g<0>)*\]|#{VariableSegment}+\??/o

  RAISE_EXCEPTION_LAMBDA = ->(_e) { raise }
  HAS_STRING_SCANNER_SCAN_BYTE = StringScanner.instance_methods.include?(:scan_byte)
end

require "liquid/version"
require "liquid/deprecations"
require "liquid/const"
require 'liquid/standardfilters'
require 'liquid/file_system'
require 'liquid/parser_switching'
require 'liquid/tag'
require 'liquid/block'
require 'liquid/parse_tree_visitor'
require 'liquid/interrupts'
require 'liquid/tags'
require "liquid/environment"
require 'liquid/lexer'
require 'liquid/parser'
require 'liquid/i18n'
require 'liquid/drop'
require 'liquid/tablerowloop_drop'
require 'liquid/forloop_drop'
require 'liquid/extensions'
require 'liquid/errors'
require 'liquid/interrupts'
require 'liquid/strainer_template'
require 'liquid/context'
require 'liquid/tag'
require 'liquid/block_body'
require 'liquid/document'
require 'liquid/variable'
require 'liquid/variable_lookup'
require 'liquid/range_lookup'
require 'liquid/resource_limits'
require 'liquid/expression'
require 'liquid/template'
require 'liquid/condition'
require 'liquid/utils'
require 'liquid/tokenizer'
require 'liquid/parse_context'
require 'liquid/partial_cache'
require 'liquid/usage'
require 'liquid/registers'
require 'liquid/template_factory'
