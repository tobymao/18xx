# frozen_string_literal: true

PRODUCTION = ENV['RACK_ENV'] == 'production'

if PRODUCTION
  require 'unicorn/worker_killer'
  #use Unicorn::WorkerKiller::MaxRequests, 1024, 2048
else
  require 'logger'
  logger = Logger.new($stdout) # rubocop:disable Lint/UselessAssignment
end

require_relative 'api'
run(Api.freeze.app)
