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

module Liquid
  FilterSeparator             = /\|/
  ArgumentSeparator           = ','.freeze
  FilterArgumentSeparator     = ':'.freeze
  VariableAttributeSeparator  = '.'.freeze
  WhitespaceControl           = '-'.freeze
  TagStart                    = /\{\%/
  TagEnd                      = /\%\}/
  VariableSignature           = /\(?[\w\-\.\[\]]\)?/
  VariableSegment             = /[\w\-]/
  VariableStart               = /\{\{/
  VariableEnd                 = /\}\}/
  VariableIncompleteEnd       = /\}\}?/
  QuotedString                = /"[^"]*"|'[^']*'/
  QuotedFragment              = /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/o
  TagAttributes               = /(\w+)\s*\:\s*(#{QuotedFragment})/o
  AnyStartingTag              = /#{TagStart}|#{VariableStart}/o
  PartialTemplateParser       = /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/om
  TemplateParser              = /(#{PartialTemplateParser}|#{AnyStartingTag})/om
  VariableParser              = /\[[^\]]+\]|#{VariableSegment}+\??/o

  singleton_class.send(:attr_accessor, :cache_classes)
  self.cache_classes = true

  autoload :Block, 'liquid/block'
  autoload :BlockBody, 'liquid/block_body'
  autoload :Condition, 'liquid/condition'
  autoload :Context, 'liquid/context'
  autoload :Document, 'liquid/document'
  autoload :Drop, 'liquid/drop'
  autoload :Expression, 'liquid/expression'
  autoload :ForloopDrop, 'liquid/forloop_drop'
  autoload :I18n, 'liquid/i18n'
  autoload :Lexer, 'liquid/lexer'
  autoload :ParseContext, 'liquid/parse_context'
  autoload :ParseTreeVisitor, 'liquid/parse_tree_visitor'
  autoload :Parser, 'liquid/parser'
  autoload :ParserSwitching, 'liquid/parser_switching'
  autoload :Profiler, 'liquid/profiler'
  autoload :RangeLookup, 'liquid/range_lookup'
  autoload :ResourceLimits, 'liquid/resource_limits'
  autoload :StandardFilters, 'liquid/standardfilters'
  autoload :Strainer, 'liquid/strainer'
  autoload :TablerowloopDrop, 'liquid/tablerowloop_drop'
  autoload :Tag, 'liquid/tag'
  autoload :Template, 'liquid/template'
  autoload :Tokenizer, 'liquid/tokenizer'
  autoload :Utils, 'liquid/utils'
  autoload :Variable, 'liquid/variable'
  autoload :VariableLookup, 'liquid/variable_lookup'
  autoload :VERSION, 'liquid/version'
end

require 'liquid/extensions'
require 'liquid/errors'
require 'liquid/interrupts'
require 'liquid/file_system'

# Load all the tags of the standard library
#
Dir["#{__dir__}/liquid/tags/*.rb"].each { |f| require f }
