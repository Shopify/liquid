# frozen_string_literal: true

require 'liquid/profiler/hooks'

module Liquid
  # Profiler enables support for profiling template rendering to help track down performance issues.
  #
  # To enable profiling, first require 'liquid/profiler'.
  # Then, to profile a parse/render cycle, pass the <tt>profile: true</tt> option to <tt>Liquid::Template.parse</tt>.
  # After <tt>Liquid::Template#render</tt> is called, the template object makes available an instance of this
  # class via the <tt>Liquid::Template#profiler</tt> method.
  #
  #   template = Liquid::Template.parse(template_content, profile: true)
  #   output  = template.render
  #   profile = template.profiler
  #
  # This object contains all profiling information, containing information on what tags were rendered,
  # where in the templates these tags live, and how long each tag took to render.
  #
  # This is a tree structure that is Enumerable all the way down, and keeps track of tags and rendering times
  # inside of <tt>{% include %}</tt> tags.
  #
  #   profile.each do |node|
  #     # Access to the node itself
  #     node.code
  #
  #     # Which template and line number of this node.
  #     # The top-level template name is `nil` by default, but can be set in the Liquid::Context before rendering.
  #     node.partial
  #     node.line_number
  #
  #     # Render time in seconds of this node
  #     node.render_time
  #
  #     # If the template used {% include %}, this node will also have children.
  #     node.children.each do |child2|
  #       # ...
  #     end
  #   end
  #
  # Profiler also exposes the total time of the template's render in <tt>Liquid::Profiler#total_render_time</tt>.
  #
  # All render times are in seconds. There is a small performance hit when profiling is enabled.
  #
  class Profiler
    include Enumerable

    class Timing
      attr_reader :code, :partial, :line_number, :children, :total_time, :self_time
      alias_method :render_time, :total_time

      def initialize(node, template_name)
        @code        = node.respond_to?(:raw) ? node.raw : node
        @partial     = template_name
        @line_number = node.respond_to?(:line_number) ? node.line_number : nil
        @children    = []
      end

      def self.start(node, template_name)
        new(node, template_name).tap(&:start)
      end

      def start
        @start_time = monotonic_time
      end

      def finish
        @total_time = monotonic_time - @start_time

        if @children.empty?
          @self_time = @total_time
        else
          total_children_time = 0
          @children.each do |child|
            total_children_time += child.total_time
          end
          @self_time = @total_time - total_children_time
        end
      end

      private

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end

    def self.profile_node_render(node, template_name)
      if Profiler.current_profile && node.respond_to?(:render)
        Profiler.current_profile.start_node(node, template_name)
        output = yield
        Profiler.current_profile.end_node
        output
      else
        yield
      end
    end

    def self.current_profile
      Thread.current[:liquid_profiler]
    end

    attr_reader :total_render_time

    def initialize
      @root_timing  = Timing.new("", nil)
      @timing_stack = [@root_timing]
    end

    def start
      Thread.current[:liquid_profiler] = self
      @render_start_at = monotonic_time
    end

    def stop
      Thread.current[:liquid_profiler] = nil
      @total_render_time = monotonic_time - @render_start_at
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

    def start_node(node, template_name)
      @timing_stack.push(Timing.start(node, template_name))
    end

    def end_node
      timing = @timing_stack.pop
      timing.finish

      @timing_stack.last.children << timing
    end

    private

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
