module JsonFilter
  
  def json(object)
    object.reject {|k,v| k == "collections" }.to_json
  end
  
end