module Liquid

  # Used to render the content of the parent block.
  #
  #   {% extends home %}
  #   {% block content }{{ block.super }}{% endblock %}
  #
  class InheritedBlockDrop < Drop

    def initialize(block)
      @block = block
    end

    def name
      @block.name
    end

    def super
      @block.call_super(@context)
    end

  end

end