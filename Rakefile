# frozen_string_literal: true

unless ENV['RACK_ENV'] == 'production'
  require 'rspec/core/rake_task'
  require 'rubocop/rake_task'

  # Specs
  RSpec::Core::RakeTask.new(:spec)
  RuboCop::RakeTask.new

  task default: %i[spec rubocop]
end

# Migrate
migrate = lambda do |env, version|
  ENV['RACK_ENV'] = env
  require_relative 'db'
  require 'logger'
  Sequel.extension :migration
  DB.loggers << Logger.new($stdout) if DB.loggers.empty?
  Sequel::Migrator.apply(DB, 'migrate', version)
end

desc 'Migrate test database to latest version'
task :test_up do
  migrate.call('test', nil)
end

desc 'Migrate test database all the way down'
task :test_down do
  migrate.call('test', 0)
end

desc 'Migrate test database all the way down and then back up'
task :test_bounce do
  migrate.call('test', 0)
  Sequel::Migrator.apply(DB, 'migrate')
end

desc 'Migrate development database to latest version'
task :dev_up do
  migrate.call('development', nil)
end

desc 'Migrate development database to all the way down'
task :dev_down do
  migrate.call('development', 0)
end

desc 'Migrate development database all the way down and then back up'
task :dev_bounce do
  migrate.call('development', 0)
  Sequel::Migrator.apply(DB, 'migrate')
end

desc 'Migrate production database to latest version'
task :prod_up do
  migrate.call('production', nil)
end

desc 'irb with -I lib/ -I assets/app/'
task :irb do
  sh 'irb -I lib/ -I assets/app/'
end

# Shell

irb = proc do |env|
  ENV['RACK_ENV'] = env
  trap('INT', 'IGNORE')
  dir, base = File.split(FileUtils::RUBY)
  cmd = if base.sub!(/\Aruby/, 'irb')
          File.join(dir, base)
        else
          "#{FileUtils::RUBY} -S irb"
        end
  sh "#{cmd} -r ./models"
end

desc 'Open irb shell in test mode'
task :test_irb do
  irb.call('test')
end

desc 'Open irb shell in development mode'
task :dev_irb do
  irb.call('development')
end

desc 'Open irb shell in production mode'
task :prod_irb do
  irb.call('production')
end

# Other

desc 'Annotate Sequel models'
task 'annotate' do
  ENV['RACK_ENV'] = 'development'
  require_relative 'models'
  DB.loggers.clear
  require 'sequel/annotate'
  Sequel::Annotate.annotate(Dir['models/*.rb'])
end

desc 'Precompile assets for production'
task :precompile do
  require_relative 'lib/assets'
  bundle = Assets.new(cache: false, make_map: false, compress: true, gzip: true).combine

  # Copy to the pin directory
  git_rev = `git rev-parse --short HEAD`.strip
  pin_dir = Assets::OUTPUT_BASE + Assets::PIN_DIR
  FileUtils.mkdir_p(pin_dir)
  FileUtils.cp("#{bundle}.gz", "#{pin_dir}/#{git_rev}.js.gz")
end

desc 'Profile loading data'
task 'stackprof', [:json] do |_task, args|
  require 'stackprof'
  require_relative 'lib/engine'
  StackProf.run(mode: :cpu, out: 'stackprof.dump', raw: true, interval: 10) do
    100.times do
      data = JSON.parse(File.read(args[:json]))
      Engine::GAMES_BY_TITLE[data['title']].new(
        data['players'].map { |p| p['name'] },
        id: data['id'],
        actions: data['actions'],
      )
    end
  end
end

desc 'Migrate JSON'
task 'migrate_json', [:json] do |_task, args|
  require_relative 'models'
  require_relative 'lib/engine'
  require_relative 'migrate_game'
  migrate_json(args[:json])
end
