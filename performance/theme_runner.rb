# This profiler run simulates Shopify.
# We are looking in the tests directory for liquid files and render them within the designated layout file.
# We will also export a substantial database to liquid which the templates can render values of. 
# All this is to make the benchmark as non syntetic as possible. All templates and tests are lifted from
# direct real-world usage and the profiler measures code that looks very similar to the way it looks in 
# Shopify which is likely the biggest user of liquid in the world which something to the tune of several 
# million Template#render calls a day. 

require 'rubygems'
require 'active_support'
require 'yaml'
require 'digest/md5'
require File.dirname(__FILE__) + '/shopify/liquid'
require File.dirname(__FILE__) + '/shopify/database.rb'

class ThemeRunner

  # Load all templates into memory, do this now so that 
  # we don't profile IO. 
  def initialize
    @tests = Dir[File.dirname(__FILE__) + '/tests/**/*.liquid'].collect do |test|
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
      compile_and_render(liquid, layout, assigns, page_template) 
       
    end
  end


  def run_profile
    RubyProf.measure_mode = RubyProf::WALL_TIME

    # Dup assigns because will make some changes to them
    assigns = Database.tables.dup

    @tests.each do |liquid, layout, template_name|

      # Compute page_tempalte outside of profiler run, uninteresting to profiler
      html = nil
      page_template = File.basename(template_name, File.extname(template_name))

      unless @started
        RubyProf.start
        RubyProf.pause
        @started = true
      end

      html = nil

      RubyProf.resume
      html = compile_and_render(liquid, layout, assigns, page_template) 
      RubyProf.pause
      

      # return the result and the MD5 of the content, this can be used to detect regressions between liquid version
      $stdout.puts "* rendered template %s, content: %s" % [template_name, Digest::MD5.hexdigest(html)]
 
      # Uncomment to dump html files to /tmp so that you can inspect for errors
      # File.open("/tmp/#{File.basename(template_name)}.html", "w+") { |fp| fp <<html}
    end

    RubyProf.stop
  end

  def compile_and_render(template, layout, assigns, page_template)    
    tmpl = Liquid::Template.new
    tmpl.assigns['page_title'] = 'Page title'
    tmpl.assigns['template'] = page_template

    content_for_layout = tmpl.parse(template).render(assigns)

    if layout
      assigns['content_for_layout'] = content_for_layout      
      tmpl.parse(layout).render(assigns)
    else
      content_for_layout
    end    
  end
end



