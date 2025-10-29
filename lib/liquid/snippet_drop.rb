# frozen_string_literal: true

module Liquid
  class SnippetDrop < Drop
    attr_reader :body, :name, :parent_name

    def initialize(body, name, parent_name)
      super()
      @body = body
      @name = name
      @parent_name = parent_name
    end

    def to_partial
      @body
    end

    def to_s
      'SnippetDrop'
    end
  end
end
