# frozen_string_literal: true

require 'sequel/core'

times = 0

begin
  times += 1
  DB = Sequel.connect(ENV['APP_DATABASE_URL'] || ENV['DATABASE_URL'])
rescue Exception => e # rubocop:disable Lint/RescueException
  puts "Sequel failed to connect: #{e}"
  sleep(5)
  retry if times < 5
end
