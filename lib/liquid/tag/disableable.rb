# frozen_string_literal: true

module Liquid
  class Tag
    module Disableable
      def render_to_output_buffer(context, output)
        if context.tag_disabled?(tag_name)
          output << disabled_error_message
          return
        end
        super
      end

      def disabled_error_message
        "#{tag_name} #{parse_context[:locale].t('errors.disabled.tag')}"
      end
    end
  end
end
