# frozen_string_literal: true

if ENV['RACK_ENV'] == 'production'
  require 'newrelic_rpm'
  require 'unicorn/worker_killer'
  use Unicorn::WorkerKiller::MaxRequests, 12_288, 16_448
  use Unicorn::WorkerKiller::Oom, (384 * (1024**2)), (512 * (1024**2))
end

# In development, Rack::Lint is active and rejects capitalized response header
# names (Rack 3 requires lowercase). Some dependencies still emit them
# (e.g. message_bus sends 'Cache-Control'), which 500s the long-poll endpoint.
# Normalize header names to lowercase so Lint is satisfied. Prod is untouched.
if ENV['RACK_ENV'] == 'development'
  class HeaderDowncase
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      [status, headers&.transform_keys(&:downcase), body]
    end
  end

  use HeaderDowncase
end

require_relative 'api'
run(Api.freeze.app)
