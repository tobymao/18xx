# frozen_string_literal: true

PRODUCTION = ENV['RACK_ENV'] == 'production'

if PRODUCTION
  require 'unicorn/worker_killer'
  use Unicorn::WorkerKiller::MaxRequests, 100, 200
end

require_relative 'api'
run(Api.freeze.app)
