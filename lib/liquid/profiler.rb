module Liquid

  # Profiler handles profiling the rendering time of individual tokens. This supports
  # the `include` tag as well, ensuring that profiling from tokens in included partials
  # are children nodes of the parent include tag, allowing drill-down to figure out exact
  # details of how long each tag is taking to render.
  class Profiler

    class Timing
      attr_reader :code, :partial, :line_number, :children

      def initialize(token, partial)
        @code        = token.raw
        @partial     = partial
        @line_number = token.line_number
        @start_time  = Time.now
        @children    = []
      end

      def finished
        @end_time = Time.now
      end

      def render_time
        @end_time - @start_time
      end

      def each(&block)
        @children.each(&block)
      end
    end

    def initialize
      @root_timing = Timing.new(Liquid::Token.new("Top", 0), "")
      @timing_stack = [@root_timing]
    end

    def start_token(token, partial)
      @timing_stack.push(Timing.new(token, partial))
    end

    def end_token(token)
      timing = @timing_stack.pop
      timing.finished

      @timing_stack.last.children << timing
    end

    def each(&block)
      @root_timing.children.each(&block)
    end

    def [](idx)
      @root_timing.children[idx]
    end

    def length
      @root_timing.children.length
    end

  end
end
