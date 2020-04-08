# frozen_string_literal: true

require 'sequel/core'

DB = Sequel.connect(ENV.delete('APP_DATABASE_URL') || ENV.delete('DATABASE_URL'))
