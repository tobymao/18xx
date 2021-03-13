# frozen_string_literal: true

require 'jaro_winkler'

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

  GAME_TITLES = GAME_META_BY_TITLE.keys
  @fuzzy_titles = GAME_TITLES.map { |t| [t, t] }.to_h

  GAME_METAS = GAME_META_BY_TITLE.values

  VISIBLE_GAMES = GAME_METAS.select { |g_m| %i[alpha beta production].include?(g_m::DEV_STAGE) }

  def self.game_by_title(title)
    title = closest_title(title)

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

  def self.meta_by_title(title)
    GAME_META_BY_TITLE[closest_title(title)]
  end

  def self.closest_title(title)
    @fuzzy_titles[title] ||= GAME_METAS.max_by do |m|
      titles = [
        m.title,
        m::GAME_LOCATION,
        m::GAME_SUBTITLE,
        m.name.split('::')[-2],
        *m::GAME_ALIASES,
      ].compact

      titles = titles.concat(titles.map { |t| t.sub(/^G?18/, '') }).uniq

      titles.uniq.map do |t|
        JaroWinkler.distance(title, t)
      end.max
    end.title
  end
end
