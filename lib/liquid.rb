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

module Liquid
  FILTER_SEPARATOR = /\|/.freeze
  ARGUMENT_SEPARATOR = ','
  FILTER_ARGUMENT_SEPARATOR = ':'
  VARIABLE_ATTRIBUTE_SEPARATOR = '.'
  WHITESPACE_CONTROL = '-'
  TAG_START = /\{\%/.freeze
  TAG_END = /\%\}/.freeze
  VARIABLE_SIGNATURE = /\(?[\w\-\.\[\]]\)?/.freeze
  VARIABLE_SEGMENT = /[\w\-]/.freeze
  VARIABLE_START = /\{\{/.freeze
  VARIABLE_END = /\}\}/.freeze
  VARIABLE_INCOMPLETE_END = /\}\}?/.freeze
  QUOTED_STRING = /"[^"]*"|'[^']*'/.freeze
  QUOTED_FRAGMENT = /#{QUOTED_STRING}|(?:[^\s,\|'"]|#{QUOTED_STRING})+/o.freeze
  TAG_ATTRIBUTES = /(\w+)\s*\:\s*(#{QUOTED_FRAGMENT})/o.freeze
  ANY_STARTING_TAG = /#{TAG_START}|#{VARIABLE_START}/o.freeze
  PARTIAL_TEMPLATE_PARSER = /#{TAG_START}.*?#{TAG_END}|#{VARIABLE_START}.*?#{VARIABLE_INCOMPLETE_END}/om.freeze
  TEMPLATE_PARSER = /(#{PARTIAL_TEMPLATE_PARSER}|#{ANY_STARTING_TAG})/om.freeze
  VARIABLE_PARSER = /\[[^\]]+\]|#{VARIABLE_SEGMENT}+\??/o.freeze

  singleton_class.send(:attr_accessor, :cache_classes)
  self.cache_classes = true
end

require 'liquid/version'
require 'liquid/parse_tree_visitor'
require 'liquid/lexer'
require 'liquid/parser'
require 'liquid/i18n'
require 'liquid/drop'
require 'liquid/tablerowloop_drop'
require 'liquid/forloop_drop'
require 'liquid/extensions'
require 'liquid/errors'
require 'liquid/interrupts'
require 'liquid/strainer'
require 'liquid/expression'
require 'liquid/context'
require 'liquid/parser_switching'
require 'liquid/tag'
require 'liquid/block'
require 'liquid/block_body'
require 'liquid/document'
require 'liquid/variable'
require 'liquid/variable_lookup'
require 'liquid/range_lookup'
require 'liquid/file_system'
require 'liquid/resource_limits'
require 'liquid/template'
require 'liquid/standardfilters'
require 'liquid/condition'
require 'liquid/utils'
require 'liquid/tokenizer'
require 'liquid/parse_context'

# Load all the tags of the standard library
#
Dir["#{__dir__}/liquid/tags/*.rb"].each { |f| require f }
