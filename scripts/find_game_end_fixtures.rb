# frozen_string_literal: true

require 'json'

require_relative 'scripts_helper'
require_relative 'validate'
require_relative '../spec/spec_helper'

SKIP = {
  '1846' => [:final_train],
  '1846 2p Variant' => [:all_closed],
  '1861' => [:bank],
  '1867' => [:bank],
}.freeze

def find_and_import_fixtures!(titles)
  Array(titles).each do |title|
    find_game_end_fixtures(title, just_one: true).each do |reason, ids|
      ids.each do |id|
        game_to_fixture!(id, reason)
      end
    end
  end
end

# return Array<String> filenames of fixtures
def fixtures(meta)
  dir = "#{FIXTURES_DIR}/#{meta.fixture_dir_name}"
  return [] unless File.directory?(dir)

  Dir.glob("#{dir}/*.json")
end

# return Array<Symbol> of checks found in `game_end_reason` in existing JSON
# fixtures
def checks_covered_by_existing_fixtures(meta)
  fixtures(meta).map do |fixture|
    data = JSON.parse(File.read(fixture))
    data['game_end_reason']&.to_sym
  end.compact.uniq
end

def find_game_end_fixtures(title, just_one: false)
  game_class = Engine.game_by_title(title)
  checks = (game_class::GAME_END_CHECK.keys - checks_covered_by_existing_fixtures(game_class.meta) - (SKIP[title] || [])).sort

  found = Hash.new { |h, k| h[k] = [] }

  where_args = {
    title: title,
    status: 'finished',
  }

  # this is throwing an unexpected error, so commenting and skipping pins in the
  # `games.each` loop instead
  # where_args[Sequel.pg_jsonb_op(:settings).key?('pin')] = false

  puts "\nQuerying for '#{title}' games..."
  puts "Looking for game end reasons: #{checks}"

  games = Game.eager(:user, :players, :actions).where(**where_args).all

  puts 'Processing games...'

  _ = games.each do |game|
    break if just_one && found.keys.sort == checks
    next if game.settings.include?('pin')

    error = false

    begin
      result = run_game(game, silent: false)
    rescue Exception => _e # rubocop:disable Lint/RescueException
      error = true
    end

    if error || result['exception']
      puts "    error in game #{game.id}"
      next
    end

    reason = result['game_end_reason']
    reason = reason.to_sym if reason

    next unless checks.include?(reason)
    next if just_one && found.include?(reason)

    puts "    found :#{reason} #{game.id}"
    found[reason] << game.id
  end

  puts "\n"

  found
end

def game_to_fixture!(id, reason)
  db_game = ::Game[id]
  game = Engine::Game.load(db_game)

  # get the game data needed to dump game to JSON
  game_data = db_game.to_h
  game_data[:actions] = game.raw_actions.map(&:to_h)

  # this is required for opening fixtures in the browser at /fixture/<title>/<id>
  game_data[:loaded] = true

  user = 1000
  group = 1000

  # ensure proper fixtures dir exists
  title = game.meta.fixture_dir_name
  dir = File.join('public', 'fixtures', title)
  FileUtils.mkdir_p(dir)
  FileUtils.chown(user, group, dir)

  # dump game to JSON file
  filename = File.join(dir, "#{title}_game_end_#{reason}.json".delete(' '))
  File.write(filename, game_data.to_json)
  FileUtils.chown(user, group, filename)

  format_fixture_json(filename)
end

# copypasta from Rakefile
def format_fixture_json(filename, pretty: nil)
  orig_text = File.read(filename)
  data = JSON.parse(orig_text)

  settings = data['fixture_format'] || {}

  # remove player names
  data['players'].each.with_index do |player, index|
    player['name'] = "Player #{index + 1}" unless /^(Player )?(\d+|[A-Z])$/.match?(player['name'])
  end

  data['user'] = { 'id' => 0, 'name' => 'You' } unless settings['keep_user']
  data['description'] = '' unless settings['keep_description']

  # remove or  chats, unless chat arg was "keep"
  if settings['chat'] == 'scrub'
    data['actions'].each do |action|
      action['message'] = 'chat' if action['type'] == 'message'
    end
  elsif settings['chat'] != 'keep'
    data['actions'].filter! do |action|
      action['type'] != 'message'
    end
  end

  if data['game_end_reason'].nil?
    game = Engine::Game.load(data).maybe_raise!
    data['game_end_reason'] = game.game_end_reason
  end

  if data.dig('fixture_format', 'keep_undos') == false
    # Get actually processed actions, i.e., remove undos/redos.
    # Also, renumber.
    game = Engine::Game.load(data).maybe_raise!
    data['actions'] = game.actions.map.with_index do |action, index|
      action_h = action.to_h
      action_h['id'] = index + 1
      action_h
    end
  end

  # if 'pretty' arg is given, any value other than "0" will produce
  # readable/diffable JSON; if arg is not given or is "0", the JSON will be
  # compressed to a single line with minimal whitespace
  if !pretty.nil? && pretty != '0'
    out_text = JSON.pretty_generate(data)
    return if out_text == orig_text

    File.write(filename, out_text)
    puts "Wrote #{filename} in \"pretty\" format"
    puts 'Use `make fixture_format` to compress it and all other fixtures before submitting a PR'
  else
    out_text = data.to_json
    return if out_text == orig_text

    File.write(filename, out_text)
    puts "Wrote #{filename}"
  end
end
