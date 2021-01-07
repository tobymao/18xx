# frozen_string_literal: true

require_relative 'g_1849'
require_relative '../config/game/g_1849_boot'

module Engine
  module Game
    class G1849Boot < G1849
      load_from_json(Config::Game::G1849Boot::JSON)

      DEV_STAGE = :prealpha
      GAME_PUBLISHER = nil

      NEW_AFG_HEXES = %w[E11 H8 I13 I17 J18 K19 L12 L20 O9].freeze

      def home_token_locations(corporation)
        raise NotImplementedError unless corporation.name == 'AFG'

        NEW_AFG_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end
      end

      def self.title
        '1849Boot'
      end
    end
  end
end
