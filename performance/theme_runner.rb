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
  def initialize
    @tests = []
    Dir[__dir__ + '/tests/**/*.liquid'].each do |test|
      next if File.basename(test) == 'theme.liquid'

      test_name = File.basename(File.dirname(test)) + "/" + File.basename(test)
      theme_name = File.basename(File.dirname(test))
      template_name = File.basename(test)
      layout_path = File.dirname(test) + '/theme.liquid'

      test = {
        test_name: test_name,
        liquid: File.read(test),
        layout: File.file?(layout_path) ? File.read(layout_path) : nil,
        template_name: template_name,
        theme_name: theme_name,
        theme_path: File.realpath(File.dirname(test)),
      }

      @tests << test
    end
  end

  def find_test(test_name)
    @tests.find do |test_hash|
      test_hash[:test_name] == test_name
    end
  end

  attr_accessor :tests

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
    tmpl, assigns, layout = compiled_test.values_at(:tmpl, :assigns, :layout)
    if layout
      assigns['content_for_layout'] = tmpl.render!(assigns)
      layout.render!(assigns)
    else
      tmpl.render!(assigns)
    end
  end

  def compile_and_render(test)
    compiled_test = compile_test(test[:liquid], test[:layout], test[:template_name], test[:theme_path])
    render_template(compiled_test)
  end

  def compile_all_tests
    @compiled_tests = []
    @tests.each do |test_hash|
      @compiled_tests << compile_test(
        test_hash[:liquid],
        test_hash[:layout],
        test_hash[:template_name],
        test_hash[:theme_path],
      )
    end
    @compiled_tests
  end

  def compile_test(template, layout, template_name, theme_path)
    tmpl = Liquid::Template.new
    tmpl.assigns['page_title']   = 'Page title'
    tmpl.assigns['template']     = template_name
    tmpl.registers[:file_system] = ThemeRunner::FileSystem.new(theme_path)

    parsed_template = tmpl.parse(template)

    assigns = Database.tables.dup
    if layout
      parsed_layout = tmpl.parse(layout).dup
      { tmpl: parsed_template, assigns: assigns, layout: parsed_layout }
    else
      { tmpl: parsed_template, assigns: assigns }
    end
  end
end
