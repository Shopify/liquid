# frozen_string_literal: true

module Liquid
  module Compile
    module Tags
      # Compiles {% comment %}...{% endcomment %} tags
      # Also handles inline_comment (#) and doc tags
      #
      # Comments produce no output
      class CommentCompiler
        def self.compile(_tag, _compiler, code)
          # Comments produce no output
          code.line "# (liquid comment)"
        end
      end
    end
  end
end
