# frozen_string_literal: true

require_relative 'g_1849'
require_relative '../config/game/g_1849_boot'

module Engine
  module Game
    class G1849Boot < G1849
      load_from_json(Config::Game::G1849Boot::JSON)

      DEV_STAGE = :prealpha
      GAME_PUBLISHER = nil

      def self.title
        '1849Boot'
      end
    end
  end
end
