module Liquid
  
  # Capture stores the result of a block into a variable without rendering it inplace.
  #
  #   {% capture heading %}
  #     Monkeys!
  #   {% endcapture %}
  #   ...
  #   <h1>{{ monkeys }}</h1>
  #
  # Capture is useful for saving content for use later in your template, such as 
  # in a sidebar or footer.
  #
  class Capture < Block
    Syntax = /(\w+)/

    def initialize(tag_name, markup, tokens)      
      if markup =~ Syntax
        @to = $1
      else
        raise SyntaxError.new("Syntax Error in 'capture' - Valid syntax: capture [var]")
      end
      
      super       
    end

    def render(context)
      output = super
      context[@to] = output.to_s
      ''
    end
  end  
  
  Template.register_tag('capture', Capture)
end