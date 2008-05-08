require 'webrick'
require 'rexml/document'

require File.dirname(__FILE__) + '/../../lib/liquid'
require File.dirname(__FILE__) + '/liquid_servlet'
require File.dirname(__FILE__) + '/example_servlet'

# Setup webrick
server = WEBrick::HTTPServer.new( :Port => ARGV[1] || 3000 )
server.mount('/', Servlet)
trap("INT"){ server.shutdown }
server.start