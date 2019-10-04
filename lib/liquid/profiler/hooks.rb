# frozen_string_literal: true

module Liquid
  class BlockBody
    def render_node_with_profiling(context, output, node)
      Profiler.profile_node_render(node) do
        render_node_without_profiling(context, output, node)
      end
    end

    alias_method :render_node_without_profiling, :render_node
    alias_method :render_node, :render_node_with_profiling
  end

  class Include < Tag
    def render_to_output_buffer_with_profiling(context, output)
      Profiler.profile_children(context.evaluate(@template_name_expr).to_s) do
        render_to_output_buffer_without_profiling(context, output)
      end
    end

    alias_method :render_to_output_buffer_without_profiling, :render_to_output_buffer
    alias_method :render_to_output_buffer, :render_to_output_buffer_with_profiling
  end
end
