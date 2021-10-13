# frozen_string_literal: true

require_relative 'engine/jaro_winkler'

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

  VISIBLE_GAMES = GAME_METAS.select do |game_meta|
    !game_meta::GAME_IS_VARIANT_OF && %i[alpha beta production].include?(game_meta::DEV_STAGE)
  end

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
    return VISIBLE_GAMES.first.title unless title
    return @fuzzy_titles[title] if @fuzzy_titles[title]

    title = title.upcase
    @fuzzy_titles[title] ||= fuzzy_candidates.max_by do |_, candidates|
      candidates.map do |candidate|
        JaroWinkler.distance(title, candidate)
      end.max
    end.first
  end

  def self.fuzzy_candidates
    @fuzzy_candidates ||= GAME_METAS.map do |m|
      module_name = m.name.split('::')[-2]

      candidates = [
        m.title,
        m.full_title,
        m::GAME_SUPERTITLE,
        m::GAME_SUBTITLE,
        module_name,
        module_name.sub(/^G/, ''),
        module_name.sub(/^G18/, ''),
        *m::GAME_ALIASES,
        m::GAME_LOCATION,
      ].flatten.compact.map(&:upcase).uniq
      candidates.concat(candidates.flat_map { |c| c.split(/[:,. ]+/) })
      candidates = candidates.uniq.reject(&:empty?)

      [m.title, candidates]
    end.to_h
  end
end
