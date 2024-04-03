# frozen_string_literal: true

require_relative 'scripts_helper'

def get_games(statuses = %w[active finished])
  Game.where(status: statuses).all
end

def migrate_games!(games)
  games.each { |g| migrate!(g) }
end

def migrate!(game)
  if game.settings['legacy_seed']
    puts "#{game.id} already has a legacy_seed. Skipping migration."
    return
  end

  if game.settings['player_order'].nil?
    # set player order as in `ordered_players()` in models/game.rb
    player_ids = game.players.map(&:id).sort
    order = player_ids.shuffle(random: Random.new(game.settings['seed'] || 1))
    game.settings['player_order'] = order
  end

  # preserve the seed, just in case
  seed = game.settings.delete('seed')
  game.settings['legacy_seed'] = seed if seed

  # populate seed so seeds from old games may be copied to new games
  game.settings['seed'] = game.id

  game.save
end

def delete_legacy_seeds!
  where_kwargs = { Sequel.pg_jsonb_op(:settings).key?('legacy_seed') => true }

  Game.where(**where_kwargs).all.each do |game|
    game.settings.delete('legacy_seed')
    game.save
  end
end
