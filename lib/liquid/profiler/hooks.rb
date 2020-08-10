# frozen_string_literal: true

module Liquid
  module BlockBodyProfilingHook
    def render_node(context, output, node)
      Profiler.profile_node_render(node) do
        super
      end
    end
  end
  BlockBody.prepend(BlockBodyProfilingHook)

  module IncludeProfilingHook
    def render_to_output_buffer(context, output)
      Profiler.profile_children(context.evaluate(@template_name_expr).to_s) do
        super
      end
    end
  end
  Include.prepend(IncludeProfilingHook)
end
