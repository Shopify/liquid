# frozen_string_literal: true

require 'test_helper'
require 'yaml'

# Load Shopify-style tags and filters for performance templates
require_relative '../../performance/shopify/comment_form'
require_relative '../../performance/shopify/paginate'
require_relative '../../performance/shopify/json_filter'
require_relative '../../performance/shopify/money_filter'
require_relative '../../performance/shopify/shop_filter'
require_relative '../../performance/shopify/tag_filter'
require_relative '../../performance/shopify/weight_filter'

# Acceptance tests for compiled templates
#
# These tests run every performance benchmark template through both
# the interpreted Liquid renderer and the compiled Ruby renderer,
# verifying that outputs match exactly.
#
# Run with: RUBY_BOX=1 ruby -W:no-experimental -Ilib:test test/unit/compile_acceptance_test.rb
class CompileAcceptanceTest < Minitest::Test
  include Liquid

  PERFORMANCE_DIR = File.expand_path('../../performance', __dir__)
  TESTS_DIR = File.join(PERFORMANCE_DIR, 'tests')
  DATABASE_FILE = File.join(PERFORMANCE_DIR, 'shopify/vision.database.yml')

  class << self
    def database
      @database ||= load_database
    end

    def load_database
      db = if YAML.respond_to?(:unsafe_load_file)
        YAML.unsafe_load_file(DATABASE_FILE)
      else
        YAML.load_file(DATABASE_FILE)
      end

      # From vision source - link products to collections
      db['products'].each do |product|
        collections = db['collections'].find_all do |collection|
          collection['products'].any? { |p| p['id'].to_i == product['id'].to_i }
        end
        product['collections'] = collections
      end

      # Key tables by handles
      db = db.each_with_object({}) do |(key, values), assigns|
        assigns[key] = values.each_with_object({}) do |v, h|
          h[v['handle']] = v
        end
      end

      # Standard direct accessors
      db['collection'] = db['collections'].values.first
      db['product'] = db['products'].values.first
      db['blog'] = db['blogs'].values.first
      db['article'] = db['blog']['articles'].first
      db['cart'] = {
        'total_price' => db['line_items'].values.inject(0) { |sum, item| sum + item['line_price'] * item['quantity'] },
        'item_count' => db['line_items'].values.inject(0) { |sum, item| sum + item['quantity'] },
        'items' => db['line_items'].values,
      }

      db
    end

    def register_shopify_extensions!
      return if @extensions_registered

      env = Liquid::Environment.default
      env.register_tag('paginate', Paginate)
      env.register_tag('form', CommentForm)
      env.register_filter(JsonFilter)
      env.register_filter(MoneyFilter)
      env.register_filter(WeightFilter)
      env.register_filter(ShopFilter)
      env.register_filter(TagFilter)

      @extensions_registered = true
    end
  end

  # File system for {% render %} and {% include %} tags
  class TestFileSystem
    def initialize(path)
      @path = path
    end

    def read_template_file(template_path)
      File.read(File.join(@path, "#{template_path}.liquid"))
    end
  end

  def setup
    self.class.register_shopify_extensions!
    @database = self.class.database
  end

  # Find all test templates and generate a test method for each
  Dir.glob(File.join(TESTS_DIR, '**/*.liquid')).each do |template_path|
    # Skip theme.liquid files - they're layouts, not standalone templates
    next if File.basename(template_path) == 'theme.liquid'

    # Extract theme name and template name for test method name
    relative_path = template_path.sub("#{TESTS_DIR}/", '')
    theme_name = File.dirname(relative_path)
    template_name = File.basename(relative_path, '.liquid')

    test_method_name = "test_#{theme_name}_#{template_name}".gsub(/[^a-zA-Z0-9_]/, '_')

    define_method(test_method_name) do
      run_acceptance_test(template_path, theme_name, template_name)
    end
  end

  private

  def run_acceptance_test(template_path, theme_name, template_name)
    # Read the template
    template_source = File.read(template_path)

    # Check for a theme layout
    theme_path = File.join(File.dirname(template_path), 'theme.liquid')
    layout_source = File.exist?(theme_path) ? File.read(theme_path) : nil

    # Set up assigns
    assigns = @database.dup
    assigns['page_title'] = 'Test Page'
    assigns['template'] = template_name

    # Set up file system for partials
    file_system = TestFileSystem.new(File.dirname(template_path))

    # Render with interpreted Liquid
    interpreted_output = render_interpreted(template_source, layout_source, assigns, file_system)

    # Render with compiled Ruby
    compiled_output = render_compiled(template_source, layout_source, assigns, file_system)

    # Compare outputs
    assert_equal(
      interpreted_output,
      compiled_output,
      "Output mismatch for #{theme_name}/#{template_name}.liquid\n" \
      "Interpreted length: #{interpreted_output.length}\n" \
      "Compiled length: #{compiled_output.length}\n" \
      "First difference at: #{find_first_diff(interpreted_output, compiled_output)}"
    )
  end

  def render_interpreted(template_source, layout_source, assigns, file_system)
    template = Template.parse(template_source)
    template.registers[:file_system] = file_system

    content = template.render!(assigns.dup)

    if layout_source
      layout = Template.parse(layout_source)
      layout.registers[:file_system] = file_system
      layout_assigns = assigns.dup
      layout_assigns['content_for_layout'] = content
      layout.render!(layout_assigns)
    else
      content
    end
  end

  def render_compiled(template_source, layout_source, assigns, file_system)
    template = Template.parse(template_source)
    compiled = template.compile_to_ruby

    # Set up filter handler with Shopify filters
    filter_handler = Class.new do
      include JsonFilter
      include MoneyFilter
      include WeightFilter
      include ShopFilter
      include TagFilter
    end.new

    compiled.filter_handler = filter_handler

    content = compiled.call(assigns.dup, registers: { file_system: file_system })

    if layout_source
      layout = Template.parse(layout_source)
      layout_compiled = layout.compile_to_ruby
      layout_compiled.filter_handler = filter_handler
      layout_assigns = assigns.dup
      layout_assigns['content_for_layout'] = content
      layout_compiled.call(layout_assigns, registers: { file_system: file_system })
    else
      content
    end
  end

  def find_first_diff(str1, str2)
    min_len = [str1.length, str2.length].min
    diff_pos = (0...min_len).find { |i| str1[i] != str2[i] } || min_len

    context_start = [0, diff_pos - 20].max
    context_end = [str1.length, str2.length, diff_pos + 30].min

    "position #{diff_pos}:\n" \
    "  Interpreted: #{str1[context_start...context_end].inspect}\n" \
    "  Compiled:    #{str2[context_start...context_end].inspect}"
  end
end
