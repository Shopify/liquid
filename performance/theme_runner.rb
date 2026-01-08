# frozen_string_literal: true

# This profiler run simulates Shopify.
# We are looking in the tests directory for liquid files and render them within the designated layout file.
# We will also export a substantial database to liquid which the templates can render values of.
# All this is to make the benchmark as non synthetic as possible. All templates and tests are lifted from
# direct real-world usage and the profiler measures code that looks very similar to the way it looks in
# Shopify which is likely the biggest user of liquid in the world which something to the tune of several
# million Template#render calls a day.

require_relative 'shopify/liquid'
require_relative 'shopify/database'

class ThemeRunner
  class FileSystem
    def initialize(path)
      @path = path
    end

    # Called by Liquid to retrieve a template file
    def read_template_file(template_path)
      File.read(@path + '/' + template_path + '.liquid')
    end
  end

  # Initialize a new liquid ThemeRunner instance
  # Will load all templates into memory, do this now so that we don't profile IO.
  def initialize(strictness: {})
    @strictness = strictness
    @tests = []
    Dir[__dir__ + '/tests/**/*.liquid'].each do |test|
      next if File.basename(test) == 'theme.liquid'

      theme_path = File.realpath(File.dirname(test))
      theme_name = File.basename(theme_path)
      test_name = theme_name + "/" + File.basename(test)
      template_name = File.basename(test, '.liquid')
      layout_path = theme_path + '/theme.liquid'

      test = {
        test_name: test_name,
        liquid: File.read(test),
        layout: File.file?(layout_path) ? File.read(layout_path) : nil,
        template_name: template_name,
        theme_name: theme_name,
        theme_path: theme_path,
      }

      @tests << test
    end
  end

  def find_test(test_name)
    @tests.find do |test_hash|
      test_hash[:test_name] == test_name
    end
  end

  attr_reader :tests

  # `compile` will test just the compilation portion of liquid without any templates
  def compile_all
    @tests.each do |test_hash|
      Liquid::Template.new.parse(test_hash[:liquid])
      Liquid::Template.new.parse(test_hash[:layout])
    end
  end

  # `tokenize` will just test the tokenizen portion of liquid without any templates
  def tokenize_all
    ss = StringScanner.new("")
    @tests.each do |test_hash|
      tokenizer = Liquid::Tokenizer.new(
        source: test_hash[:liquid],
        string_scanner: ss,
        line_numbers: true,
      )
      while tokenizer.shift; end
    end
  end

  # `run` is called to benchmark rendering and compiling at the same time
  def run_all
    @tests.each do |test|
      compile_and_render(test)
    end
  end

  # `render` is called to benchmark just the render portion of liquid
  def render_all
    @compiled_tests ||= compile_all_tests
    @compiled_tests.each do |test|
      render_template(test)
    end
  end

  def run_one_test(test_name)
    test = find_test(test_name)
    compile_and_render(test)
  end

  private

  def render_template(compiled_test)
    tmpl, layout, assigns = compiled_test.values_at(:tmpl, :layout, :assigns)
    if layout
      assigns['content_for_layout'] = tmpl.render!(assigns, @strictness)
      rendered_layout = layout.render!(assigns, @strictness)
      rendered_layout
    else
      tmpl.render!(assigns, @strictness)
    end
  end

  def compile_and_render(test)
    compiled_test = compile_test(test)
    render_template(compiled_test)
  end

  def compile_all_tests
    @compiled_tests = []
    @tests.each do |test_hash|
      @compiled_tests << compile_test(test_hash)
    end
    @compiled_tests
  end

  def compile_test(test_hash)
    theme_path, template_name, layout, liquid = test_hash.values_at(:theme_path, :template_name, :layout, :liquid)

    assigns = Database.tables.dup
    assigns.merge!({
      'title' => 'Page title',
      'page_title' => 'Page title',
      'content_for_header' => '',
      'template' => template_name,
    })

    fs = ThemeRunner::FileSystem.new(theme_path)

    result = {}
    result[:assigns] = assigns
    result[:tmpl] = Liquid::Template.parse(liquid, registers: { file_system: fs })

    if layout
      result[:layout] = Liquid::Template.parse(layout, registers: { file_system: fs })
    end

    result
  end
end
