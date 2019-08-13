module Liquid
  class Comment < Block
    def render_to_output_buffer(_context, output)
      output
    end

    def unknown_tag(_tag, _markup, _tokens)
    end

    def blank?
      true
    end

    def format(left, right)
      output = "{%#{"-" if left} comment #{"-" if right}%}"
      output << super
      output << "{%#{"-" if left} endcomment #{"-" if right}%}"
    end
  end

  Template.register_tag('comment'.freeze, Comment)
end
