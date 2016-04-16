# This profiler run simulates Shopify.
# We are looking in the tests directory for liquid files and render them within the designated layout file.
# We will also export a substantial database to liquid which the templates can render values of.
# All this is to make the benchmark as non syntetic as possible. All templates and tests are lifted from
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

  # Load all templates into memory, do this now so that
  # we don't profile IO.
  def initialize
    @tests = Dir[__dir__ + '/tests/**/*.liquid'].collect do |test|
      next if File.basename(test) == 'theme.liquid'

      theme_path = File.dirname(test) + '/theme.liquid'

      [File.read(test), (File.file?(theme_path) ? File.read(theme_path) : nil), test]
    end.compact
  end

  def compile
    # Dup assigns because will make some changes to them

    @tests.each do |liquid, layout, template_name|
      tmpl = Liquid::Template.new
      tmpl.parse(liquid)
      tmpl = Liquid::Template.new
      tmpl.parse(layout)
    end
  end

  def run
    # Dup assigns because will make some changes to them
    assigns = Database.tables.dup

    @tests.each do |liquid, layout, template_name|
      # Compute page_tempalte outside of profiler run, uninteresting to profiler
      page_template = File.basename(template_name, File.extname(template_name))
      compile_and_render(liquid, layout, assigns, page_template, template_name)
    end
  end

  def compile_and_render(template, layout, assigns, page_template, template_file)
    tmpl = Liquid::Template.new
    tmpl.assigns['page_title'] = 'Page title'
    tmpl.assigns['template'] = page_template
    tmpl.registers[:file_system] = ThemeRunner::FileSystem.new(File.dirname(template_file))

    content_for_layout = tmpl.parse(template).render!(assigns)

    if layout
      assigns['content_for_layout'] = content_for_layout
      tmpl.parse(layout).render!(assigns)
    else
      content_for_layout
    end
  end
end
