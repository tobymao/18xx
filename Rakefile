# frozen_string_literal: true

unless ENV['RACK_ENV'] == 'production'
  require 'parallel_tests'
  require 'rspec/core/rake_task'
  require 'rubocop/rake_task'
  require_relative 'lib/assets'

  # Specs
  RSpec::Core::RakeTask.new(:spec)
  RuboCop::RakeTask.new do |task|
    task.requires << 'rubocop-performance'
  end

  desc 'Run spec in parallel'
  task :spec_parallel do
    Assets.new.combine
    ParallelTests::CLI.new.run(['--type', 'rspec'])
  end

  task default: %i[spec_parallel rubocop]
end

# Migrate
migrate = lambda do |env, version, truncate = false|
  ENV['RACK_ENV'] = env
  require_relative 'db'
  require 'logger'
  Sequel.extension :migration
  DB.loggers << Logger.new($stdout) if DB.loggers.empty?
  DB[:actions].truncate if truncate && DB.tables.include?(:actions)
  Sequel::Migrator.apply(DB, 'migrate', version)
end

desc 'Migrate development database to latest version'
task :dev_up do
  migrate.call('development', nil)
end

desc 'Migrate development database to version x (0 if no arg given)'
task :dev_down, [:version] do |_t, args|
  migrate.call('development', args[:version].to_i, true)
end

desc 'Migrate development database down to version x (0 if no arg given) and then back up'
task :dev_bounce, [:version] do |_t, args|
  migrate.call('development', args[:version].to_i, true)
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
  assets = Assets.new(cache: false, compress: true, gzip: true)
  assets.combine(:all)

  # Copy to the pin directory
  git_rev = `git rev-parse --short HEAD`.strip
  version_epochtime = Time.now.strftime('%s')
  pin_dir = Assets::OUTPUT_BASE + Assets::PIN_DIR
  File.write(Assets::OUTPUT_BASE + '/assets/version.json', JSON.dump(
    hash: git_rev,
    url: "https://github.com/tobymao/18xx/commit/#{git_rev}",
    version_epochtime: version_epochtime,
  ))
  FileUtils.mkdir_p(pin_dir)
  assets.pin("#{pin_dir}#{git_rev}.js.gz")

  assets.clean_intermediate_output_files
end

desc 'Profile loading data'
task 'stackprof', [:json] do |_task, args|
  require 'stackprof'
  require_relative 'lib/engine'
  starttime = Time.new
  StackProf.run(mode: :cpu, out: 'stackprof.dump', raw: true, interval: 10) do
    10.times do
      Engine::Game.load(args[:json])
    end
  end
  endtime = Time.new
  puts "#{endtime - starttime} seconds"
end

desc 'Migrate JSON'
task 'migrate_json', [:json] do |_task, args|
  require_relative 'models'
  require_relative 'lib/engine'
  require_relative 'migrate_game'
  migrate_json(args[:json])
end

desc 'Remove player names, chats, and whitespace from public/fixtures/*/<id>.json'
task 'fixture_format', [:id, :chat, :pretty] do |_task, args|
  Dir.glob("public/fixtures/*/#{args[:id]}.json").each do |filename|
    format_fixture_json(filename, chat: args[:chat], pretty: args[:pretty])
  end
end

def format_fixture_json(filename, chat: nil, pretty: nil)
  data = JSON.parse(File.read(filename))

  # remove player names
  data['players'].each.with_index do |player, index|
    player['name'] = "Player #{index}"
  end

  # remove chats, unless chat arg was "keep"
  if chat != 'keep'
    data['actions'].filter! do |action|
      action['type'] != 'message'
    end
  end

  # TODO: get rid of undone actions

  # if 'pretty' arg is given, any value other than "0" will produce
  # readable/diffable JSON; if arg is not given or is "0", the JSON will be
  # compressed to a single line with minimal whitespace
  if !pretty.nil? && pretty != '0'
    File.write(filename, JSON.pretty_generate(data))
    puts "Wrote #{filename} in \"pretty\" format"
    puts 'Use `rake fixture_format[<id>]` to compress it before submitting a PR'
  else
    File.write(filename, data.to_json)
    puts "Wrote #{filename}"
  end
end

desc 'Add game from DB to fixtures/, downloading it if necessary'
task 'fixture_import', [:id] do |_task, args|
  require_relative 'db'
  require_relative 'scripts/import_game'

  # get game from DB
  retried = false
  begin
    game_id = args[:id].to_i
    db_game = ::Game[game_id]
    raise "Cannot find game in local DB: #{game_id}" if db_game.nil?

    puts 'Found game in local DB'
  rescue RuntimeError => e
    raise e if retried

    # if game wasn't in DB, import to DB from 18xx.games API, then try once
    # more
    puts 'Downloading game from 18xx.games...'
    import_game(game_id)
    retried = true
    retry
  end

  game = Engine::Game.load(db_game)

  # get the game data needed to dump game to JSON
  game_data = db_game.to_h
  game_data[:actions] = game.raw_actions.map(&:to_h)

  user = 1000
  group = 1000

  # ensure proper fixtures dir exists
  title = game_data[:title]
  dir = File.join('public', 'fixtures', title)
  FileUtils.mkdir_p(dir)
  FileUtils.chown(user, group, dir)

  # dump game to JSON file
  filename = File.join(dir, "#{game_id}.json")
  File.write(filename, JSON.pretty_generate(game_data))
  FileUtils.chown(user, group, filename)

  format_fixture_json(filename, pretty: true)

  sh "git add #{filename}"
end
