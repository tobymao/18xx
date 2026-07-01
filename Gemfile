source 'https://rubygems.org'

# Core Engine Dependencies
gem 'argon2', '~> 2.2.0'
gem 'message_bus', '~> 4.2.0'
gem 'opal', '~> 1.8.2'
gem 'racc', '~> 1.7.3'
gem 'rake', '~> 13.0.6'
gem 'redis', '~> 4.6.0'
gem 'require_all', '~> 3.0.0'
gem 'roda', '~> 3.97.0'
gem 'rufus-scheduler', '~> 3.8.2'
gem 'sequel', '~> 5.55.0'
gem 'tilt', '~> 2.3.0'
gem 'sequel-pg_advisory_lock'
gem 'snabberb', '~> 1.5.4'

# Development & Test Tools
group :development, :test do
  gem 'byebug'
  gem 'parallel_tests', '~> 3.8.1'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rerun', '~> 0.14.0'
  gem 'rspec', '~> 3.11.0'
  gem 'rubocop', '~> 1.27.0'
  gem 'rubocop-performance', '~> 1.13.3'
end

# Web server dependencies removed to bypass native macOS compilation errors:
gem 'mini_racer', platforms: :ruby, force_ruby_platform: true
gem 'unicorn'
gem 'unicorn-worker-killer'
gem "pg", "~> 1.6"
