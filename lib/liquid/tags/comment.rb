module Liquid
  class Comment < Block
    def render(context)
      ''
    end

    def self.blank?
      true
    end
  end

  Template.register_tag('comment', Comment)
end
