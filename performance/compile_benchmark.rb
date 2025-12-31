# frozen_string_literal: true

# Benchmark comparing compiled Ruby code vs interpreted Liquid rendering
#
# Usage:
#   ruby performance/compile_benchmark.rb
#
# This benchmark compares:
# 1. Standard Liquid render (interpreted)
# 2. Compiled Ruby render (compiled once, executed many times)
# 3. Compile + render (includes compilation overhead)

require 'benchmark/ips'
require_relative 'ruby33_compat'  # Add peek_byte for Ruby 3.3 compatibility
require_relative 'shopify/liquid'
require_relative 'shopify/database'

RubyVM::YJIT.enable if defined?(RubyVM::YJIT)

# Combined filter handler that includes all Shopify filters
class ShopifyFilterHandler
  include JsonFilter
  include MoneyFilter
  include ShopFilter
  include TagFilter
  include WeightFilter
end

class CompileBenchmarkRunner
  def initialize
    @templates = []
    @compiled_procs = []
    @filter_handler = ShopifyFilterHandler.new

    # Load test templates
    load_templates
  end

  def load_templates
    puts "Loading templates..."

    test_dirs = Dir[__dir__ + '/tests/*']
    test_dirs.each do |dir|
      next unless File.directory?(dir)

      Dir[dir + '/*.liquid'].each do |file|
        next if File.basename(file) == 'theme.liquid'

        source = File.read(file)
        template = Liquid::Template.parse(source)

        @templates << {
          name: File.basename(file),
          source: source,
          template: template,
          assigns: Database.tables.dup,
        }
      end
    end

    puts "Loaded #{@templates.size} templates"

    # Pre-compile all templates
    puts "Pre-compiling templates to Ruby..."
    @templates.each do |t|
      begin
        compiled = t[:template].compile_to_ruby
        compiled.filter_handler = @filter_handler  # Set the filter handler
        t[:compiled] = compiled  # CompiledTemplate object
        t[:ruby_code] = compiled.code
        notes = []
        notes << "#{compiled.external_tags.size} external tag(s)" if compiled.has_external_tags?
        notes << "external filters" if compiled.has_external_filters?
        puts "  #{t[:name]}: #{notes.join(', ')}" unless notes.empty?
      rescue => e
        puts "  Warning: Failed to compile #{t[:name]}: #{e.message}"
        puts "    #{e.backtrace.first(3).join("\n    ")}"
        t[:compiled] = nil
      end
    end

    compilable = @templates.count { |t| t[:compiled] }
    puts "Successfully compiled #{compilable}/#{@templates.size} templates"
    puts
  end

  # Benchmark: Standard Liquid render
  def render_interpreted
    @templates.each do |t|
      t[:template].render!(t[:assigns].dup)
    end
  end

  # Benchmark: Compiled Ruby render (already compiled)
  def render_compiled
    @templates.each do |t|
      next unless t[:compiled]
      t[:compiled].call(t[:assigns].dup)
    end
  end

  # Benchmark: Compile + render (includes compilation time)
  def compile_and_render
    @templates.each do |t|
      compiled = t[:template].compile_to_ruby
      compiled.filter_handler = @filter_handler
      compiled.call(t[:assigns].dup)
    end
  end

  # Show sample output comparison
  def verify_output
    puts "Verifying output equivalence..."

    @templates.each do |t|
      next unless t[:compiled]

      assigns = t[:assigns].dup
      interpreted = t[:template].render!(assigns.dup)
      compiled = t[:compiled].call(assigns.dup)

      if interpreted == compiled
        puts "  ✓ #{t[:name]}: outputs match"
      else
        puts "  ✗ #{t[:name]}: outputs differ!"
        puts "    Interpreted length: #{interpreted.length}"
        puts "    Compiled length: #{compiled.length}"

        # Show first difference
        interpreted.chars.each_with_index do |c, i|
          if compiled[i] != c
            puts "    First diff at position #{i}:"
            puts "      Interpreted: #{interpreted[i-10, 30].inspect}"
            puts "      Compiled: #{compiled[i-10, 30].inspect}"
            break
          end
        end
      end
    end
    puts
  end

  # Show code size comparison
  def show_stats
    puts "Template Statistics:"
    puts "=" * 60

    total_liquid_size = 0
    total_ruby_size = 0

    @templates.each do |t|
      next unless t[:ruby_code]

      liquid_size = t[:source].length
      ruby_size = t[:ruby_code].length

      total_liquid_size += liquid_size
      total_ruby_size += ruby_size

      ratio = ruby_size.to_f / liquid_size
      puts "  #{t[:name]}: Liquid=#{liquid_size}b, Ruby=#{ruby_size}b (#{ratio.round(1)}x)"
    end

    puts "-" * 60
    puts "  Total: Liquid=#{total_liquid_size}b, Ruby=#{total_ruby_size}b"
    puts
  end

  def run_benchmark
    puts "Running benchmark..."
    puts "=" * 60
    puts

    Benchmark.ips do |x|
      x.time = 10
      x.warmup = 5

      x.report("Liquid render (interpreted):") do
        render_interpreted
      end

      x.report("Ruby render (pre-compiled):") do
        render_compiled
      end

      x.report("Compile + render:") do
        compile_and_render
      end

      x.compare!
    end
  end
end

# Run the benchmark
runner = CompileBenchmarkRunner.new
runner.show_stats
runner.verify_output
runner.run_benchmark
