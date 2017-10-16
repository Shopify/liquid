module Liquid
  class CommentBody < BlockBody
    def parse(tokenizer, parse_context)
      parse_context.line_number = tokenizer.line_number
      while token = tokenizer.shift
        unless token.empty?
          if token.start_with?(TAGSTART)
            whitespace_handler(token, parse_context)
            if token =~ FullToken
              tag_name = $1
              markup = $2

              if tag_name == 'comment'
                new_tag = Comment.parse(tag_name, markup, tokenizer, parse_context)
                @blank &&= new_tag.blank?
                @nodelist << new_tag
              else
                return yield tag_name, markup
              end
            end
          else
            if parse_context.trim_whitespace
              token.lstrip!
            end
            parse_context.trim_whitespace = false
            @nodelist << token
            @blank &&= !!(token =~ /\A\s*\z/)
          end
        end
        parse_context.line_number = tokenizer.line_number
      end

      yield nil, nil
    end
  end
end
