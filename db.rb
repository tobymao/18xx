# frozen_string_literal: true

require 'sequel/core'

times = 0

begin
  times += 1
  DB = Sequel.connect(ENV.delete('APP_DATABASE_URL') || ENV.delete('DATABASE_URL'))
rescue Exception # rubocop:disable Lint/RescueException
  sleep(5)
  retry if times < 3
end
