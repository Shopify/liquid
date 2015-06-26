module Liquid
  # The spaceless tag strips whitespace between HTML tags using a simple regex.
  #
  # == Usage:
  #    {% spaceless %}
  #      <h1>
  #        Hello
  #      </h1>
  #    {% endspaceless %}
  #
  class Spaceless < Block
    HTML_STRIP_SPACE_REGEXP = />\s+</

    def render(context)
      self.class.strip_html_whitespace(super)
    end

    def self.strip_html_whitespace(input)
      input.gsub(HTML_STRIP_SPACE_REGEXP, '><')
    end
  end

  Template.register_tag('spaceless'.freeze, Spaceless)
end
