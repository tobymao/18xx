# frozen_string_literal: true

require_relative 'db'
require 'sequel/model'

Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :tactical_eager_loading
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :touch

Sequel.default_timezone = :utc
Sequel.extension :migration
Sequel.extension :pg_array_ops
DB.extension :pg_array, :pg_advisory_lock, :pg_json, :pg_enum

DB.register_advisory_lock(:action_lock)

if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'
  require 'logger'
  logger = Logger.new($stdout)
  if ENV['RACK_ENV'] == 'test'
    logger.level = Logger::FATAL
  elsif ENV['DB_LOG_LEVEL']
    logger.level = Logger.const_get(ENV['DB_LOG_LEVEL'].upcase)
  end
  DB.loggers << logger
end

DB.freeze
