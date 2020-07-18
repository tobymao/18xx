# frozen_string_literal: true
# rubocop:disable all

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
    engine = Engine::GAMES_BY_TITLE[game.title].new(game.ordered_players.map(&:name), id: game.id, actions: actions)
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

def validate_all()
  page = []
  data = {}
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished]).select(:id).paged_each(rows_per_fetch: 100) do |game|
    page << game
    if page.size >= 100
      games = Game.eager(:user, :players, :actions).where(id: page.map { |p| p[:id] }).all
      _ = games.each do |game|
        data[game.id]=run_game(game)
      end
      page.clear
    end
  end

  games = Game.eager(:user, :players, :actions).where(id: page.map { |p| p[:id] }).all
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

def validate_migrated_one(id)
  game = Game[id]
  puts run_game(game, migrate_db_actions(game))
end

def revalidate_broken(filename)
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
