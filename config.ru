# frozen_string_literal: true

if ENV['RACK_ENV'] == 'production'
  require 'newrelic_rpm'
  require 'unicorn/worker_killer'
  use Unicorn::WorkerKiller::MaxRequests, 12_288, 16_448
  use Unicorn::WorkerKiller::Oom, (384 * (1024**2)), (512 * (1024**2))
end

require_relative 'api'
run(Api.freeze.app)
