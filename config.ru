# frozen_string_literal: true

dev = ENV['RACK_ENV'] == 'development'

if dev
  require 'logger'
  logger = Logger.new($stdout) # rubocop:disable Lint/UselessAssignment
end

require_relative 'api'
run(Api.freeze.app)
