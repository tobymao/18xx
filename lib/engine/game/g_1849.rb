# frozen_string_literal: true

require_relative '../config/game/g_1849'
require_relative 'base'

module Engine
  module Game
    class G1849 < Base
      register_colors(black: '#000000',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#ff0000',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1849::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Sicily'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/206628/1849-rules'
      GAME_DESIGNER = 'Federico Vellani'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849'

      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :operate
      SELL_BUY_ORDER = :sell_buy

      MARKET_TEXT = Base::MARKET_TEXT.merge(phase_limited: 'Can only enter during phase 16').freeze

      STOCKMARKET_COLORS = {
        par: :yellow,
        endgame: :orange,
        close: :purple,
        phase_limited: :blue,
      }.freeze

      def event_earthquake!
        @log << '-- Event: Messina Earthquake --'
        # Remove tile from Messina

        # Remove from game tokens on Messina

        # If Garibaldi's only token removed, close Garibaldi

        # Messina cannot be upgraded until after next stock round
      end
    end
  end
end
