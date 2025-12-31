# frozen_string_literal: true

# Compile Profiler - Measure allocations and performance of compiled vs interpreted Liquid
#
# Usage:
#   RUBY_BOX=1 ruby -W:no-experimental performance/compile_profiler.rb
#
# This tool measures:
# - Allocation count (objects created during render)
# - Time per render
# - Comparison between interpreted and compiled
#
# Results are appended to ../timings.jsonl with git hash and timestamp
#
# REQUIRES Ruby 4.0+ with RUBY_BOX=1

unless ENV['RUBY_BOX'] == '1'
  $stderr.puts "\e[31mERROR: Must run with RUBY_BOX=1\e[0m"
  $stderr.puts "Usage: RUBY_BOX=1 ruby -W:no-experimental performance/compile_profiler.rb"
  exit 1
end

require 'json'
require 'time'
require_relative '../lib/liquid'
require_relative '../lib/liquid/compile'

unless Liquid::Box.secure?
  $stderr.puts "\e[31mERROR: Ruby::Box not available. Requires Ruby 4.0+\e[0m"
  exit 1
end

class CompileProfiler
  COLORS = {
    reset:   "\e[0m",
    bold:    "\e[1m",
    red:     "\e[31m",
    green:   "\e[32m",
    yellow:  "\e[33m",
    blue:    "\e[34m",
    magenta: "\e[35m",
    cyan:    "\e[36m",
    gray:    "\e[90m",
  }.freeze

  BOX_CHARS = {
    tl: "╭", tr: "╮", bl: "╰", br: "╯",
    h: "─", v: "│",
    check: "✓", cross: "✗", arrow: "→", delta: "Δ",
  }.freeze

  TIMINGS_FILE = File.expand_path('../../timings.jsonl', __dir__)

  def initialize
    @results = {}
    @git_hash = `git rev-parse --short HEAD 2>/dev/null`.strip
    @git_hash = "unknown" if @git_hash.empty?
    @timestamp = Time.now.utc.iso8601
  end

  def c(color, text)
    "#{COLORS[color]}#{text}#{COLORS[:reset]}"
  end

  def box(title, width: 70)
    puts
    puts "#{BOX_CHARS[:tl]}#{BOX_CHARS[:h] * (width - 2)}#{BOX_CHARS[:tr]}"
    puts "#{BOX_CHARS[:v]} #{c(:bold, title)}#{' ' * (width - 4 - title.length)} #{BOX_CHARS[:v]}"
    yield if block_given?
    puts "#{BOX_CHARS[:bl]}#{BOX_CHARS[:h] * (width - 2)}#{BOX_CHARS[:br]}"
  end

  # Calculate visible length (excluding ANSI codes)
  def visible_length(str)
    str.gsub(/\e\[[0-9;]*m/, '').length
  end

  def row(label, value, width: 70)
    label_str = label.to_s
    value_str = value.to_s
    label_visible = visible_length(label_str)
    value_visible = visible_length(value_str)
    padding = width - 4 - label_visible - value_visible
    padding = 1 if padding < 1
    puts "#{BOX_CHARS[:v]} #{label_str}#{' ' * padding}#{value_str} #{BOX_CHARS[:v]}"
  end

  def separator(width: 70)
    puts "#{BOX_CHARS[:v]}#{BOX_CHARS[:h] * (width - 2)}#{BOX_CHARS[:v]}"
  end

  def measure_allocations
    GC.start
    GC.disable
    before = GC.stat(:total_allocated_objects)
    yield
    after = GC.stat(:total_allocated_objects)
    GC.enable
    after - before
  end

  def measure_time(iterations: 100)
    GC.start
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    iterations.times { yield }
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    (elapsed / iterations * 1_000_000).round(2)  # microseconds
  end

  def measure_objects
    before = ObjectSpace.count_objects.dup
    yield
    after = ObjectSpace.count_objects
    
    diff = {}
    after.each do |k, v|
      d = v - (before[k] || 0)
      diff[k] = d if d > 0
    end
    diff
  end

  def profile_template(name, source, assigns, iterations: 100)
    puts
    puts c(:cyan, "#{BOX_CHARS[:arrow]} Profiling: #{c(:bold, name)}")
    puts c(:gray, "  Template: #{source[0..60]}#{'...' if source.length > 60}")
    
    template = Liquid::Template.parse(source)
    compiled = template.compile_to_ruby

    # Warmup
    10.times { template.render(assigns.dup) }
    10.times { compiled.render(assigns.dup) }

    # Measure interpreted
    interp_allocs = measure_allocations { template.render(assigns.dup) }
    interp_time = measure_time(iterations: iterations) { template.render(assigns.dup) }
    interp_objects = measure_objects { template.render(assigns.dup) }

    # Measure compiled
    comp_allocs = measure_allocations { compiled.render(assigns.dup) }
    comp_time = measure_time(iterations: iterations) { compiled.render(assigns.dup) }
    comp_objects = measure_objects { compiled.render(assigns.dup) }

    # Calculate deltas
    alloc_delta = ((comp_allocs.to_f / interp_allocs - 1) * 100).round(1)
    time_delta = ((comp_time / interp_time - 1) * 100).round(1)

    alloc_color = alloc_delta < 0 ? :green : :red
    time_color = time_delta < 0 ? :green : :red

    box(name) do
      # Header row
      header = "#{' ' * 20}#{c(:gray, 'Interpreted')}  #{c(:cyan, 'Compiled')}  #{c(:yellow, 'Delta')}"
      row(header, "")
      separator
      # Data rows with fixed-width columns
      alloc_delta_str = "#{alloc_delta > 0 ? '+' : ''}#{alloc_delta}%"
      time_delta_str = "#{time_delta > 0 ? '+' : ''}#{time_delta}%"
      row("Allocations", "#{interp_allocs.to_s.rjust(11)}  #{comp_allocs.to_s.rjust(8)}  #{c(alloc_color, alloc_delta_str.rjust(7))}")
      row("Time (μs)", "#{interp_time.to_s.rjust(11)}  #{comp_time.to_s.rjust(8)}  #{c(time_color, time_delta_str.rjust(7))}")
      separator
      row("Objects (compiled):", "")
      comp_objects.sort_by { |_, v| -v }.first(3).each do |type, count|
        row("  #{type}", count.to_s)
      end
    end

    @results[name] = {
      interp_allocs: interp_allocs,
      comp_allocs: comp_allocs,
      interp_time: interp_time,
      comp_time: comp_time,
      alloc_delta: alloc_delta,
      time_delta: time_delta,
    }
  end

  def print_summary
    return if @results.empty?

    width = 70
    total_interp_allocs = @results.values.sum { |r| r[:interp_allocs] }
    total_comp_allocs = @results.values.sum { |r| r[:comp_allocs] }
    total_interp_time = @results.values.sum { |r| r[:interp_time] }
    total_comp_time = @results.values.sum { |r| r[:comp_time] }

    alloc_improvement = ((1 - total_comp_allocs.to_f / total_interp_allocs) * 100).round(1)
    time_improvement = ((1 - total_comp_time / total_interp_time) * 100).round(1)

    alloc_icon = alloc_improvement > 0 ? c(:green, BOX_CHARS[:check]) : c(:red, BOX_CHARS[:cross])
    time_icon = time_improvement > 0 ? c(:green, BOX_CHARS[:check]) : c(:red, BOX_CHARS[:cross])
    
    alloc_text = "#{alloc_icon} Allocations: #{c(:bold, "#{alloc_improvement}%")} #{alloc_improvement > 0 ? 'fewer' : 'more'} (#{total_comp_allocs} vs #{total_interp_allocs})"
    time_text = "#{time_icon} Time: #{c(:bold, "#{time_improvement}%")} #{time_improvement > 0 ? 'faster' : 'slower'} (#{total_comp_time.round(0)}μs vs #{total_interp_time.round(0)}μs)"

    puts
    puts "#{BOX_CHARS[:tl]}#{BOX_CHARS[:h] * (width - 2)}#{BOX_CHARS[:tr]}"
    title = "SUMMARY"
    title_pad = (width - 4 - title.length) / 2
    puts "#{BOX_CHARS[:v]} #{' ' * title_pad}#{c(:bold, title)}#{' ' * (width - 4 - title_pad - title.length)} #{BOX_CHARS[:v]}"
    puts "#{BOX_CHARS[:v]}#{BOX_CHARS[:h] * (width - 2)}#{BOX_CHARS[:v]}"
    alloc_pad = width - 4 - visible_length(alloc_text)
    puts "#{BOX_CHARS[:v]} #{alloc_text}#{' ' * alloc_pad} #{BOX_CHARS[:v]}"
    time_pad = width - 4 - visible_length(time_text)
    puts "#{BOX_CHARS[:v]} #{time_text}#{' ' * time_pad} #{BOX_CHARS[:v]}"
    puts "#{BOX_CHARS[:bl]}#{BOX_CHARS[:h] * (width - 2)}#{BOX_CHARS[:br]}"

    # Write to timings.jsonl
    write_timings(total_interp_allocs, total_comp_allocs, total_interp_time, total_comp_time, 
                  alloc_improvement, time_improvement)
  end

  def write_timings(total_interp_allocs, total_comp_allocs, total_interp_time, total_comp_time,
                    alloc_improvement, time_improvement)
    entry = {
      timestamp: @timestamp,
      git_hash: @git_hash,
      ruby_version: RUBY_VERSION,
      summary: {
        alloc_improvement_pct: alloc_improvement,
        time_improvement_pct: time_improvement,
        total_interp_allocs: total_interp_allocs,
        total_comp_allocs: total_comp_allocs,
        total_interp_time_us: total_interp_time.round(2),
        total_comp_time_us: total_comp_time.round(2),
      },
      benchmarks: @results.transform_values { |r|
        {
          interp_allocs: r[:interp_allocs],
          comp_allocs: r[:comp_allocs],
          interp_time_us: r[:interp_time],
          comp_time_us: r[:comp_time],
          alloc_delta_pct: r[:alloc_delta],
          time_delta_pct: r[:time_delta],
        }
      }
    }

    File.open(TIMINGS_FILE, 'a') do |f|
      f.puts JSON.generate(entry)
    end

    puts
    puts c(:gray, "Results appended to #{TIMINGS_FILE}")
  end

  def run_all
    puts c(:bold, "\n🔬 Liquid Compile Profiler")
    puts c(:gray, "   Measuring allocations and performance...\n")

    profile_template(
      "Simple variable",
      "Hello, {{ name }}!",
      { "name" => "World" }
    )

    profile_template(
      "Variable with filter",
      "{{ name | upcase | prepend: 'Hello, ' | append: '!' }}",
      { "name" => "world" }
    )

    profile_template(
      "Simple loop",
      "{% for item in items %}{{ item }} {% endfor %}",
      { "items" => %w[a b c d e] }
    )

    profile_template(
      "Loop with forloop",
      "{% for item in items %}{{ forloop.index }}: {{ item }} {% endfor %}",
      { "items" => %w[a b c d e] }
    )

    profile_template(
      "Nested loop",
      "{% for i in outer %}{% for j in inner %}{{ i }}.{{ j }} {% endfor %}{% endfor %}",
      { "outer" => [1, 2, 3], "inner" => %w[a b c] }
    )

    profile_template(
      "Conditionals",
      "{% if show %}{% if big %}BIG{% else %}small{% endif %}{% else %}hidden{% endif %}",
      { "show" => true, "big" => false }
    )

    profile_template(
      "Property access",
      "{{ user.profile.name }} - {{ user.profile.email }}",
      { "user" => { "profile" => { "name" => "Alice", "email" => "alice@example.com" } } }
    )

    profile_template(
      "Complex template",
      <<~LIQUID,
        {% for product in products %}
          {{ forloop.index }}. {{ product.name | upcase }}
          {% if product.on_sale %}SALE: ${{ product.price | times: 0.8 }}{% else %}${{ product.price }}{% endif %}
        {% endfor %}
      LIQUID
      { 
        "products" => [
          { "name" => "Widget", "price" => 100, "on_sale" => true },
          { "name" => "Gadget", "price" => 200, "on_sale" => false },
          { "name" => "Gizmo", "price" => 150, "on_sale" => true },
        ]
      }
    )

    print_summary
  end
end

# Run the profiler
if __FILE__ == $0
  profiler = CompileProfiler.new
  profiler.run_all
end
