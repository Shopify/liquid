require 'webrick'
require 'rexml/document'

DIR = File.expand_path(File.dirname(__FILE__))

require DIR + '/../../lib/liquid'
require DIR + '/liquid_servlet'
require DIR + '/example_servlet'

# Setup webrick
server = WEBrick::HTTPServer.new( :Port => ARGV[1] || 3000 )
server.mount('/', Servlet)
trap("INT"){ server.shutdown }
server.start
