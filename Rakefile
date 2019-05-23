# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

task :serve do
  sh "bundle exec rerun thin start --signal KILL --ignore 'coverage/*'"
end

task :irb do
  sh 'irb -I lib/'
end
