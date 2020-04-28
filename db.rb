# frozen_string_literal: true

require 'sequel/core'

protocol = 'postgres'
user = ENV.delete('POSTGRES_USER')
password = ENV.delete('POSTGRES_PASSWORD')
host = 'db'
port = 5432
db = "18xx_#{ENV['RACK_ENV']}"

db_url = "#{protocol}://#{user}:#{password}@#{host}:#{port}/#{db}"

times = 0

begin
  times += 1
  DB = Sequel.connect(db_url)
rescue Exception => e # rubocop:disable Lint/RescueException
  puts "Sequel failed to connect: #{e}"
  sleep(5)
  retry if times < 5
end
