# frozen_string_literal: true

require 'webrick'
require 'rexml/document'

require_relative '../../lib/liquid'
require_relative 'liquid_servlet'
require_relative 'example_servlet'

# Setup webrick
server = WEBrick::HTTPServer.new(Port: ARGV[1] || 3000)
server.mount('/', Servlet)
trap("INT") { server.shutdown }
server.start
