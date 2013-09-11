require "liquid/tags/raw"

module Liquid
  class Comment < Raw
    def render(context)
      ''
    end

    def blank?
      true
    end
  end

  Template.register_tag('comment', Comment)
end
