module Liquid
  class Block < Tag
    def render_token_with_profiling(token, context)
      Profiler.profile_token_render(token) do
        render_token_without_profiling(token, context)
      end
    end

    alias_method :render_token_without_profiling, :render_token
    alias_method :render_token, :render_token_with_profiling
  end

  class Include < Tag
    def render_with_profiling(context)
      Profiler.profile_children(@template_name) do
        render_without_profiling(context)
      end
    end

    alias_method :render_without_profiling, :render
    alias_method :render, :render_with_profiling
  end
end
