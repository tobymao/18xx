# frozen_string_literal: true

require_relative 'g_1849'
require_relative '../config/game/g_1849_boot'

module Engine
  module Game
    class G1849Boot < G1849
      load_from_json(Config::Game::G1849Boot::JSON)

      DEV_STAGE = :prealpha
      GAME_PUBLISHER = nil
      GAME_LOCATION = 'Southern Italy'
      GAME_RULES_URL = 'https://docs.google.com/document/d/1gNn2RmtcPWh0KpNduv3p0Lraa3iWIAV3cWcHpCu8X-E/edit'
      GAME_DESIGNER = 'Scott Petersen (Based on 1849 by Federico Vellani)'

      NEW_AFG_HEXES = %w[E11 H8 I13 I17 J18 K19 L12 L20 O9].freeze
      SMS_HEXES = %w[A9 B14 G7 H8 J18 L12 L18 L20 N20 O9 P2].freeze

      def home_token_locations(corporation)
        raise NotImplementedError unless corporation.name == 'AFG'

        NEW_AFG_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end
      end

      def self.title
        '1849: Kingdom of the Two Sicilies'
      end

      def num_trains(train)
        fewer = @players.size < 4
        case train[:name]
        when '6H'
          fewer ? 4 : 4
        when '8H'
          fewer ? 4 : 4
        when '16H'
          fewer ? 6 : 6
        end
      end

      def remove_corp

      end

    end
  end
end
