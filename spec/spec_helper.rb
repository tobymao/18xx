# frozen_string_literal: true

require 'snabberb/component'

require 'engine'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

FIXTURES_DIR = File.join(File.dirname(__FILE__), '..', 'public', 'fixtures')
