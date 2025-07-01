# frozen_string_literal: true

require_relative "tags/table_row"
require_relative "tags/echo"
require_relative "tags/if"
require_relative "tags/break"
require_relative "tags/inline_comment"
require_relative "tags/for"
require_relative "tags/assign"
require_relative "tags/ifchanged"
require_relative "tags/case"
require_relative "tags/include"
require_relative "tags/continue"
require_relative "tags/capture"
require_relative "tags/decrement"
require_relative "tags/unless"
require_relative "tags/increment"
require_relative "tags/comment"
require_relative "tags/raw"
require_relative "tags/render"
require_relative "tags/cycle"
require_relative "tags/doc"

module Liquid
  module Tags
    STANDARD_TAGS = {
      'cycle' => Cycle,
      'render' => Render,
      'raw' => Raw,
      'comment' => Comment,
      'increment' => Increment,
      'unless' => Unless,
      'decrement' => Decrement,
      'capture' => Capture,
      'continue' => Continue,
      'include' => Include,
      'case' => Case,
      'ifchanged' => Ifchanged,
      'assign' => Assign,
      'for' => For,
      '#' => InlineComment,
      'break' => Break,
      'if' => If,
      'echo' => Echo,
      'tablerow' => TableRow,
      'doc' => Doc,
    }.freeze
  end
end
