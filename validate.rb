# frozen_string_literal: true
# rubocop:disable all

require_relative 'models'

Dir['./models/**/*.rb'].sort.each { |file| require file }
Sequel.extension :pg_json_ops
require './lib/engine'
load 'migrate_game.rb'


$count = 0
$total = 0
$total_time = 0

def run_game(game, actions = nil)
  actions ||= game.actions.map(&:to_h)
  data={'id':game.id, 'title': game.title, 'status':game.status}
  begin
    $total += 1
    time = Time.now
    engine = Engine::GAMES_BY_TITLE[game.title].new(game.ordered_players.map(&:name), id: game.id, actions: actions, optional_rules: game.settings['optional_rules_selected'] || [])
    time = Time.now - time
    $total_time += time
    data['finished']=true

    data['actions']=engine.actions.size
    data['result']=engine.result
  rescue Exception => e # rubocop:disable Lint/RescueException
    $count += 1
    data['finished']=false
    #data['stack']=e.backtrace
    data['exception']=e
  end
  data
end

def validate_all(*titles)
  $count = 0
  $total = 0
  $total_time = 0
  page = []
  data = {}

  where_args = {Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished]}
  where_args[:title] = titles if titles.any?

  DB[:games].order(:id).where(**where_args).select(:id).paged_each(rows_per_fetch: 100) do |game|
    page << game
    if page.size >= 100
      where_args2 = {id: page.map { |p| p[:id] }}
      where_args2[:title] = titles if titles.any?
      games = Game.eager(:user, :players, :actions).where(**where_args2).all
      _ = games.each do |game|
        data[game.id]=run_game(game)
      end
      page.clear
    end
  end

  where_args3 = {id: page.map { |p| p[:id] }}
  where_args3[:title] = titles if titles.any?

  games = Game.eager(:user, :players, :actions).where(**where_args3).all
  _ = games.each do |game|
    data[game.id]=run_game(game)
  end
  puts "#{$count}/#{$total} avg #{$total_time / $total}"
  data['summary']={'failed':$count, 'total':$total, 'total_time':$total_time, 'avg_time':$total_time / $total}
  File.write("validate.json", JSON.pretty_generate(data))
end

def validate_one(id)
  game = Game[id]
  puts run_game(game)
end

def validate_migrated_one_mem(id)
  game = Game[id]
  puts run_game(game, migrate_db_actions_in_mem(game))
end
def validate_migrated_one(id)
  game = Game[id]
  puts run_game(game, migrate_db_actions(game))
end

def revalidate_broken(filename)
  $count = 0
  $total = 0
  $total_time = 0
  data = JSON.parse(File.read(filename))
  data = data.map do |game, val|
    if game != 'summary' && !val['finished'] && !val['pin']
      reload_game = Game[val['id']]
      d = run_game(reload_game, migrate_db_actions(reload_game))
      d['original']=val
      #[game,run_game(reload_game)]
      [game,d]
    end
  end.compact.to_h
  data['updated_summary']={'failed':$count, 'total':$total, 'total_time':$total_time, 'avg_time':$total_time / $total}
  File.write("revalidate.json", JSON.pretty_generate(data))
end

def validate_json(filename)
  data = JSON.parse(File.read(filename))
  players = data['players'].map { |p| p['name'] }
  engine = Engine::GAMES_BY_TITLE[data['title']]
  engine.new(players, id: data['id'], actions: data['actions'], optional_rules: data.dig('settings', 'optional_rules_selected') || [])
end

def pin_games(pin_version, game_ids)
  game_ids.each do |id|
    data = Game[id]
    if (pin = data.settings['pin'])
      puts "Game #{id} already pinned to #{pin}"
    else
      data.settings['pin'] = pin_version
    end
    data.save
  end
end
