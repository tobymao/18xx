# frozen_string_literal: true
# rubocop:disable all

require_relative 'models'

Dir['./models/**/*.rb'].sort.each { |file| require file }
Sequel.extension :pg_json_ops
require_relative 'lib/engine'
$failed = []

def migrate_db_actions(data)
  players = data.players.map { |p| [p[:name], p[:id].to_s] }.to_h
  if data.settings['players']
    data.settings['players'] = data.settings['players'].map {|p, h| [players[p] || p, h]}.to_h
    data.save
  end
end

def migrate_one(id)
  DB[:games].order(:id).where(id: id).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data)
    }
  end
end

def migrate_all()
  DB[:games].order(Sequel.desc(:id)).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished]).select(:id).paged_each(rows_per_fetch: 1) do |game|
    puts game[:id]
    games = Game.eager(:user, :players).where(id: [game[:id]]).all
    games.each do |data|
      migrate_db_actions(data)
    end
  end
end
