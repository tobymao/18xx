# frozen_string_literal: true

PRODUCTION = ENV['RACK_ENV'] == 'production'

if PRODUCTION
  require 'unicorn/worker_killer'
  use Unicorn::WorkerKiller::MaxRequests, 3072, 4096
  use Unicorn::WorkerKiller::Oom, (192 * (1024**2)), (256 * (1024**2))
end

require_relative 'api'
run(Api.freeze.app)
