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
    game_meta = const::Meta if const.constants.include?(:Meta)
    [game_meta.title, game_meta] if game_meta
  end.compact.to_h

  GAME_METAS = GAME_META_BY_TITLE.values

  VISIBLE_GAMES = GAME_METAS.select { |g_m| %i[alpha beta production].include?(g_m::DEV_STAGE) }

  def self.game_by_title(title)
    @games[title] ||= Engine::Game.constants.map do |c|
      const = Game.const_get(c)
      game = const::Game if const.constants.include?(:Game)
      game if game&.title == title
    end.compact.first
  end

  def self.all_game_titles
    Engine::Game.constants.sort.map do |c|
      const = Game.const_get(c)
      game = const::Game if const.constants.include?(:Game)
      game&.title
    end.compact
  end
end
