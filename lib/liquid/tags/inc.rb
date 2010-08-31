#require 'rubygems'
#require 'ruby-debug'

module Liquid
  
  # inc is used in a place where one needs to insert a counter
  #     into a template, and needs the counter to survive across
  #     multiple instantiations of the template.
  #
  #     if the variable does not exist, it is created with value 0.

  #   Hello: {% inc variable %}
  #
  # gives you:
  #
  #    Hello: 0
  #    Hello: 1
  #    Hello: 2
  #
  class Inc < Tag
    def initialize(tag_name, markup, tokens)      
      @variable = markup.strip

      super    
    end    
  
    def render(context)
      value = context.environments.first[@variable] ||= 0
      context.environments.first[@variable] = value + 1
      value.to_s
    end
  
    private
  end
  
  Template.register_tag('inc', Inc)
end
