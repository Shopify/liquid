require 'liquid'

if defined? Rails 
  require 'extras/liquid_view'
  Liquid.init_rails
end
