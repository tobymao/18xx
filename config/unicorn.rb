# frozen_string_literal: true

require_relative '../db'
require 'message_bus'

PRODUCTION = ENV['RACK_ENV'] == 'production'

listen 9292
worker_processes PRODUCTION ? 2 : 1
timeout PRODUCTION ? 30 : 60
preload_app true

before_fork do |_server, _worker|
  DB.disconnect
end

after_fork do |_server, _worker|
  MessageBus.after_fork
end
