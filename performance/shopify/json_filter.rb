require 'json'

module JsonFilter
  def json(object)
    JSON.dump(object.reject { |k, v| k == "collections" })
  end
end
