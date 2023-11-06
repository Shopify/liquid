# frozen_string_literal: true

module Liquid
  # @liquid_public_docs
  # @liquid_type tag
  # @liquid_category syntax
  # @liquid_name comment
  # @liquid_summary
  #   Prevents an expression from being rendered or output.
  # @liquid_description
  #   Any text inside `comment` tags won't be output, and any Liquid code will be parsed, but not executed.
  # @liquid_syntax
  #   {% comment %}
  #     content
  #   {% endcomment %}
  # @liquid_syntax_keyword content The content of the comment.
  class Comment < Block
    def render_to_output_buffer(_context, output)
      output
    end

    def unknown_tag(_tag, _markup, _tokens)
    end

    def blank?
      true
    end

    private

    def parse_body(body, tokens)
      if parse_context.depth >= MAX_DEPTH
        raise StackLevelError, "Nesting too deep"
      end
      parse_context.depth += 1
      comment_tag_depth = 1

      begin
        # Consume tokens without creating child nodes.
        # The children tag doesn't require to be a valid Liquid except the comment and raw tag.
        # The child comment and raw tag must be closed.
        while token = tokens.send(:shift)
          tag_name_match = BlockBody::FullToken.match(token)

          next if tag_name_match.nil?

          tag_name = tag_name_match[2]

          if tag_name == "raw"
            # raw tags are required to be closed
            raw_tag_closed = false

            while token = tokens.send(:shift)
              if token =~ Raw::FullTokenPossiblyInvalid && "endraw" == Regexp.last_match(2)
                raw_tag_closed = true
                break
              end
            end

            raise_tag_never_closed("raw") unless raw_tag_closed
            next
          end

          if tag_name_match[2] == "comment"
            comment_tag_depth += 1
            next
          elsif tag_name_match[2] == "endcomment"
            comment_tag_depth -= 1

            return false if comment_tag_depth.zero?
          end
        end

        raise_tag_never_closed(block_name)
      ensure
        parse_context.depth -= 1
      end

      false
    end
  end

  Template.register_tag('comment', Comment)
end
