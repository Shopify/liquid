# frozen_string_literal: true

require 'bundler/inline'

gemfile(true) do
  source "https://rubygems.org"
  gem 'liquid'
end

require 'liquid'

class Parser
  def initialize(template)
    @template = template
  end

  def parse
    @parsed_template = Liquid::Template.parse(@template)
  end

  def test_parse
    document = @parsed_template.root

    variables = []

    if document.is_a?(Liquid::Document)
      body = document.body

      if body.is_a?(Liquid::BlockBody)
        body.nodelist.each do |node|
          next unless node.is_a?(Liquid::Variable)

          puts node.inspect
          variable_name = node.name.name
          variables << variable_name
        end
      end
    end
    puts "Variables: #{variables}"
  end

  def render
    @parsed_template.render
  end
end

starter_template = "{{ foo }}"
starter_template_2 = "{{foo}}, {{bar}}"
starter_template_2_1 = "{{ foo }} and {{ bar }}"
starter_template_3 = "{% assign foo = 'bar' %}{{ foo }}"
# Let's start small here
template = <<~LIQUID
  {% assign foo = 'bar' %}
  {{ foo }}
LIQUID

parser = Parser.new(starter_template)
parser.parse
parser.test_parse
