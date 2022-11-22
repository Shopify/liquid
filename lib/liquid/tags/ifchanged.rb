# frozen_string_literal: true

module Liquid
  class Ifchanged < Block
    def self.migrate(tag_name, _markup, tokenizer, parse_context)
      new_markup = "" # markup was ignored

      new_body, unknown_tag = migrate_body(tag_name, tokenizer, parse_context)
      raise SyntaxError if unknown_tag

      [new_markup, new_body]
    end

    def render_to_output_buffer(context, output)
      block_output = +''
      super(context, block_output)

      if block_output != context.registers[:ifchanged]
        context.registers[:ifchanged] = block_output
        output << block_output
      end

      output
    end
  end

  Template.register_tag('ifchanged', Ifchanged)
end
