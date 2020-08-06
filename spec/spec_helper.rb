# frozen_string_literal: true

require 'snabberb/component'

Dir['spec/helpers/*.rb'].each do |f|
  require "./#{f}"
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SpecHelpers
end
