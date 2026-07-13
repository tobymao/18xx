# frozen_string_literal: true

# File: 18xx-tournament/run_server.rb
require 'bundler/setup'
require 'rack'

# Load the authentic engine app layer
require_relative 'api'

# Detect the available server environment within the localized bundle
server_handler = %w[puma falcon webrick].find do |handler|
  Rack::Handler.get(handler)
  true
rescue LoadError, NameError
  false
end

if server_handler
  puts '=========================================================='
  puts " Booting Authentic 18xx Engine Server via #{server_handler.upcase} "
  puts ' Local Link: http://127.0.0.1:9292 '
  puts '=========================================================='

  # Run the Roda App class directly as the Rack interface target
  Rack::Handler.get(server_handler).run(Api, Port: 9292, Host: '127.0.0.1')
else
  warn '[Failure] No valid Rack server architecture (Puma/WEBrick) detected in bundle.'
  exit 1
end
