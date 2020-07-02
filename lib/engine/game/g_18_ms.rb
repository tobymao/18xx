# frozen_string_literal: true

require_relative '../config/game/g_18_ms'
require_relative 'base'

module Engine
  module Game
    class G18MS < Base
      load_from_json(Config::Game::G18MS::JSON)

      GAME_LOCATION = 'Mississippi, USA'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]

      HOME_TOKEN_TIMING = :operating_round

      #      def init_round
      #        Round::G18MS::Draft.new(@players.reverse, game: self)
      #      end
    end
  end
end
