# frozen_string_literal: true

module Liquid
  module BlockBodyProfilingHook
    def render_node(context, output, node)
      Profiler.profile_node_render(node, context.template_name) do
        super
      end
    end
  end
  BlockBody.prepend(BlockBodyProfilingHook)
end
