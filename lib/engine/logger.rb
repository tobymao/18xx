# frozen_string_literal: true

require 'logger'

LOGGER = Logger.new($stdout)

module Engine
  module Logger
    def self.set_level(level, production = false)
      LOGGER.level =
        if level
          level.to_i
        elsif production
          ::Logger::FATAL
        else
          ::Logger::DEBUG
        end
    end
  end
end

if RUBY_ENGINE == 'opal'
  # see `App#setup_logger` in assets/app/app.rb for browser logger setup
else
  Engine::Logger.set_level(ENV['ENGINE_LOG_LEVEL'], ENV['RACK_ENV'] == 'production')
end
