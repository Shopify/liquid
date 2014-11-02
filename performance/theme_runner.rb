# This profiler run simulates Shopify.
# We are looking in the tests directory for liquid files and render them within the designated layout file.
# We will also export a substantial database to liquid which the templates can render values of.
# All this is to make the benchmark as non syntetic as possible. All templates and tests are lifted from
# direct real-world usage and the profiler measures code that looks very similar to the way it looks in
# Shopify which is likely the biggest user of liquid in the world which something to the tune of several
# million Template#render calls a day.

require File.dirname(__FILE__) + '/shopify/liquid'
require File.dirname(__FILE__) + '/shopify/database.rb'

class ThemeRunner
  class FileSystem

    def initialize(path)
      @path = path
    end

    # Called by Liquid to retrieve a template file
    def read_template_file(template_path, context)
      File.read(@path + '/' + template_path + '.liquid')
    end
  end

  # Load all templates into memory, do this now so that
  # we don't profile IO.
  def initialize
    @tests = Dir[File.dirname(__FILE__) + '/tests/**/*.liquid'].collect do |test|
      next if File.basename(test) == 'theme.liquid'

      theme_path = File.dirname(test) + '/theme.liquid'

      [File.read(test), (File.file?(theme_path) ? File.read(theme_path) : nil), test]
    end.compact
    @parsed = @tests.map do |liquid, layout, template_name|
      [Liquid::Template.parse(liquid), Liquid::Template.parse(layout), template_name]
    end
    @marshaled = @parsed.map do |liquid, layout, template_name|
      [Marshal.dump(liquid), Marshal.dump(layout), template_name]
    end
  end

  def parse
    @tests.each do |liquid, layout, template_name|
      Liquid::Template.parse(liquid)
      Liquid::Template.parse(layout)
    end
  end

  def marshal_load
    @marshaled.each do |liquid, layout, template_name|
      Marshal.load(liquid)
      Marshal.load(layout)
    end
  end

  def render
    @parsed.each do |liquid, layout, template_name|
      render_once(liquid, layout, template_name)
    end
  end

  def load_and_render
    @marshaled.each do |liquid, layout, template_name|
      render_once(Marshal.load(liquid), Marshal.load(layout), template_name)
    end
  end

  def parse_and_render
    @tests.each do |liquid, layout, template_name|
      render_once(Liquid::Template.parse(liquid), Liquid::Template.parse(layout), template_name)
    end
  end

  def render_once(template, layout, template_name)
    # Dup assigns because will make some changes to them
    assigns = Database.tables.dup

    assigns['page_title'] = 'Page title'
    assigns['template'] = File.basename(template_name, File.extname(template_name))
    template.registers[:file_system] = ThemeRunner::FileSystem.new(File.dirname(template_name))

    content_for_layout = template.render!(assigns)

    if layout
      assigns['content_for_layout'] = content_for_layout
      layout.render!(assigns)
    else
      content_for_layout
    end
  end
end
