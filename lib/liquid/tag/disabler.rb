# frozen_string_literal: true

module Liquid
  class Tag
    module Disabler
      def render_to_output_buffer(context, output)
        context.with_disabled_tags(self.class.disabled_tags) do
          super
        end
      end
    end
  end
end
