# frozen_string_literal: true

begin
  require_relative '.env.rb'
rescue LoadError # rubocop:disable Lint/SuppressedException
end

require 'sequel/core'

DB = Sequel.connect(ENV.delete('APP_DATABASE_URL') || ENV.delete('DATABASE_URL'))
