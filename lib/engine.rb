# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree 'engine/game'
else
  require 'require_all'
  require_rel 'engine/game'
end

module Engine
  GAMES = Game.constants.map do |c|
    klass = Game.const_get(c)
    next if !klass.is_a?(Class) || klass == Game::Base

    klass
  end.compact

  # Games that are alpha or above
  VISIBLE_GAMES = GAMES.select { |game| %i[alpha beta production].include? game::DEV_STAGE }

  GAMES_BY_TITLE = GAMES.map { |game| [game.title, game] }.to_h
end
