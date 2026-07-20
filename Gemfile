# frozen_string_literal: true

source 'https://rubygems.org'

gem 'argon2'
# These stopped being default gems in ruby 3.4 (logger is on the same path for
# 4.0), so they have to be declared or the gems that require them fail to load:
# base64 -> opal's source map builder, bigdecimal -> sequel, logger -> newrelic.
gem 'base64'
gem 'bigdecimal'
gem 'logger'
gem 'message_bus'
gem 'mini_racer'
gem 'newrelic_rpm'
gem 'opal'
gem 'racc'
gem 'rake'
gem 'redis'
gem 'require_all'
gem 'roda'
gem 'rufus-scheduler'
gem 'sequel'
gem 'sequel_pg'
gem 'sequel-pg_advisory_lock'
gem 'snabberb'
gem 'unicorn'
gem 'unicorn-worker-killer'

group :development do
  gem 'pry-byebug'
  gem 'rerun'
  gem 'rubocop'
  gem 'rubocop-performance', require: 'false'
  gem 'sequel-annotate'
  gem 'stackprof'
  gem 'tilt'
end

group :test do
  gem 'parallel_tests'
  gem 'rspec'
end
