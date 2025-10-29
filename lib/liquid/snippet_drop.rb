# frozen_string_literal: true

module Liquid
  class SnippetDrop < Drop
    attr_reader :body, :name, :filename

    def initialize(body, name, filename)
      super()
      @body = body
      @name = name
      @filename = filename
    end

    def to_partial
      @body
    end

    def to_s
      'SnippetDrop'
    end
  end
end
