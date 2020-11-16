# frozen_string_literal: true
# rubocop:disable all

require_relative 'models'

Dir['./models/**/*.rb'].sort.each { |file| require file }
Sequel.extension :pg_json_ops
require_relative 'lib/engine'
$failed = []

def migrate_db_actions(data)
  players = data.players.map { |p| [p[:name], p[:id]] }.to_h
  actions = data.actions
  DB.transaction do
    actions.each do |action|
      if action.action['entity_type']=="player"
        id = players[action.action["entity"]]
        if id
          action.action["entity"] = id
          action.save
        end
      end
    end

    begin
      engine = Engine::GAMES_BY_TITLE[data.title]
      engine.new(
        data.ordered_players.map(&:name),
        id: data.id,
        actions: [],
        optional_rules: data.settings['optional_rules']&.map(&:to_sym),
      )
    rescue Exception => e
      puts 'Something went wrong', e
      $failed << data.id
      raise Sequel::Rollback
    end
  end
end

def migrate_data(data)
  players = data['players'].map { |p| [p['name'], p['id']] }.to_h
  actions = data['actions']
  actions.each do |action|
    if action['entity_type']=="player"
      id = players[action["entity"]]
      action["entity"] = id if id
    end
  end
  data
end

def migrate_json(filename)
  data = migrate_data(JSON.parse(File.read(filename)))
  File.write(filename, JSON.pretty_generate(data))
end

def migrate_one(id)
  DB[:games].order(:id).where(id: id).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data)
    }
  end

  puts $failed
end

def migrate_all()
  DB[:games].order(Sequel.desc(:id)).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished]).select(:id).paged_each(rows_per_fetch: 1) do |game|
    puts game[:id]
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each do |data|
      migrate_db_actions(data)
    end
  end

  puts $failed
end
