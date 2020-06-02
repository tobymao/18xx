# frozen_string_literal: true

require_relative 'db'
require 'sequel/model'

Sequel::Model.cache_associations = false if ENV['RACK_ENV'] == 'development'

Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :prepared_statements
Sequel::Model.plugin :tactical_eager_loading
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :touch
Sequel::Model.plugin :subclasses unless ENV['RACK_ENV'] == 'development'

Sequel.default_timezone = :utc
Sequel.extension :migration
Sequel.extension :pg_array_ops
DB.extension :pg_array, :pg_advisory_lock, :pg_json, :pg_enum

DB.register_advisory_lock(:action_lock)
DB.register_advisory_lock(:turn_lock, :pg_try_advisory_lock)

if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'] == 'test'
  require 'logger'
  LOGGER = Logger.new($stdout)
  LOGGER.level = Logger::FATAL if ENV['RACK_ENV'] == 'test'
  DB.loggers << LOGGER
end

unless ENV['RACK_ENV'] == 'development'
  Sequel::Model.freeze_descendents
  DB.freeze
end
