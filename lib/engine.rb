# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree 'engine/game'
else
  require 'require_all'
  require_rel 'engine/game'
end

module Engine
  @games = {}

  GAME_META_BY_TITLE = Game.constants.sort.map do |c|
    const = Game.const_get(c)
    game =
      if const.constants.include?(:Meta)
        const::Meta
      elsif const.is_a?(Class) && const != Game::Base && const.ancestors.include?(Game::Base)
        const
      end
    [game.title, game] if game
  end.compact.to_h

  GAME_METAS = GAME_META_BY_TITLE.values

  VISIBLE_GAMES = GAME_METAS.select { |game| %i[alpha beta production].include?(game::DEV_STAGE) }

  def self.game_by_title(title)
    @games[title] ||= Engine::Game.constants.map do |c|
      const = Game.const_get(c)
      game =
        if const.constants.include?(:Game)
          const::Game
        elsif const.is_a?(Class) && const != Game::Base && const.ancestors.include?(Game::Base)
          const
        end
      game if game&.title == title
    end.compact.first
  end

  def self.player_range(game)
    game::PLAYER_RANGE || game::CERT_LIMIT.keys.minmax
  end
end
