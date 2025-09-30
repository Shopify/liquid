# frozen_string_literal: true

module Liquid
  class SnippetDrop < Drop
    attr_reader :body

    def initialize(body)
      super()
      @body = body
    end

    def to_s
      'SnippetDrop'
    end
  end
end
