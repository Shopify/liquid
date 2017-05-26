module Liquid

  # Extend allows templates to inherit from other templates
  #
  # Extend from another template like:
  #
  #   {% extend 'products' %}
  #
  require 'lib/liquid/tags/include'

  class Extend < Liquid::Include
    Syntax = /(#{QuotedFragment}+)/o

    def initialize(tag_name, markup, tokens)
      if markup =~ Syntax
        @template_name = $1
      else
        raise SyntaxError.new(options[:locale].t("errors.syntax.extend"))
      end

      super
    end

    def render(context)
      context[@template_name] = @template_name
      template = load_cached_partial(context)
      template.render(context)
    end
  end

  Template.register_tag('extend', Extend)
end
