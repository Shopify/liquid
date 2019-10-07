# frozen_string_literal: true

module Liquid
  class TemplateFactory
    def self.for(_template_name)
      Liquid::Template
    end
  end
end
