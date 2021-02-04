# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree 'engine/game'
else
  require 'require_all'
  require_rel 'engine/game'
end

module Engine
  @games = {}

  # Game or Meta
  GAMES = Game.constants.map do |c|
    klass = Game.const_get(c)

    if c.start_with?('G')
      if klass.is_a?(Class)
        klass
      elsif klass.is_a?(Module)
        klass::Meta
      end
    end
  end.compact

  # Game or Meta; all that are alpha or above
  VISIBLE_GAMES = GAMES.select { |game| %i[alpha beta production].include?(game::DEV_STAGE) }

  # Game or Meta
  GAMES_BY_TITLE = GAMES.map { |game| [game.title, game] }.to_h

  def self.get_game(game_meta)
    require_tree "engine/game/#{game_meta.fs_name}" if RUBY_ENGINE == 'opal'

    Engine::Game.constants
      .map { |c| Engine::Game.const_get(c) }
      .select { |c| c.constants.include?(:Game) }
      .map { |c| c.const_get(:Game) }
      .find { |c| c.title == game_meta.title }
  end

  # Game
  def self.game_by_title(title)
    return @games[title] if @games[title]
    return @games[title] = GAMES_BY_TITLE[title] if GAMES_BY_TITLE[title].is_a?(Class)

    game_meta = GAMES_BY_TITLE[title]
    game = get_game(game_meta)

    if game.nil? && RUBY_ENGINE == 'opal'
      game_by_title(game_meta::DEPENDS_ON) if game_meta::DEPENDS_ON

      src = "/assets/#{game_meta.fs_name}.js"

      # add <script> tag to DOM to load the target game file
      `var s = document.createElement('script');
       s.type = 'text/javascript';
       s.src = #{src};
       s.async = false;
       document.body.appendChild(s);`
      game = get_game(game_meta)
    end

    @games[title] = game
  end

  def self.player_range(game)
    game::PLAYER_RANGE || game::CERT_LIMIT.keys.minmax
  end
end
