module Liquid
  class Comment < Block
    def render(context)
      ''
    end

    def unknown_tag(tag, markup, tokens)
    end

    def blank?
      true
    end
  end

  Template.register_tag('comment', Comment)
end
