# frozen_string_literal: true

require 'json'

module JsonFilter
  def json(object)
    JSON.dump(object.reject { |k, _v| k == "collections" })
  end
end
