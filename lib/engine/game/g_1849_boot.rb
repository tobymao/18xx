# frozen_string_literal: true

require_relative 'g_1849'
require_relative '../config/game/g_1849_boot'

module Engine
  module Game
    class G1849Boot < G1849
      load_from_json(Config::Game::G1849Boot::JSON)

      DEV_STAGE = :alpha
      GAME_PUBLISHER = nil
      GAME_LOCATION = 'Southern Italy'
      GAME_RULES_URL = 'https://docs.google.com/document/d/1gNn2RmtcPWh0KpNduv3p0Lraa3iWIAV3cWcHpCu8X-E/edit'
      GAME_DESIGNER = 'Scott Petersen (Based on 1849 by Federico Vellani)'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849#variants-and-optional-rules'

      NEW_AFG_HEXES = %w[E11 H8 I13 I17 J18 K19 L12 L20 O9].freeze
      NEW_PORT_HEXES = %w[B16 G5 J20 L16].freeze
      NEW_SMS_HEXES = %w[B14 G7 H8 J18 L12 L18 L20 N20 O9 P2].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'green_par': ['144 Par Available',
                      'Corporations may now par at 144 (in addition to 67 and 100)'],
        'brown_par': ['216 Par Available',
                      'Corporations may now par at 216 (in addition to 67, 100, and 144)'],
        'earthquake': ['Avezzano Earthquake',
                       'Avezzano (C7) loses connection to Rome, revenue reduced to 10.']
      ).freeze

      AVZ_CODE = 'town=revenue:10;path=a:4,b:_0,track:narrow'.freeze

      NEW_GRAY_REVENUE_CENTERS =
        {
          'A7':
            {
              '4H': 10,
              '6H': 10,
              '8H': 40,
              '10H': 40,
              '12H': 60,
              '16H': 60,
            },
          'N2':
           {
             '4H': 30,
             '6H': 30,
             '8H': 50,
             '10H': 50,
             '12H': 80,
             '16H': 80,
           },
          'C5':
           {
             '4H': 60,
             '6H': 60,
             '8H': 90,
             '10H': 90,
             '12H': 120,
             '16H': 120,
           },
          'J18':
           {
             '4H': 20,
             '6H': 20,
             '8H': 30,
             '10H': 30,
             '12H': 40,
             '16H': 40,
           },
          'B14':
           {
             '4H': 20,
             '6H': 20,
             '8H': 30,
             '10H': 30,
             '12H': 40,
             '16H': 40,
           },
          'I13':
           {
             '4H': 20,
             '6H': 20,
             '8H': 30,
             '10H': 30,
             '12H': 40,
             '16H': 40,
           },
          'N20':
           {
             '4H': 20,
             '6H': 20,
             '8H': 30,
             '10H': 30,
             '12H': 40,
             '16H': 40,
           },
        }.freeze

      def home_token_locations(corporation)
        raise NotImplementedError unless corporation.name == 'AFG'

        NEW_AFG_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end
      end

      def check_other(route)
        return if (route.stops.map(&:hex).map(&:id) & NEW_PORT_HEXES).empty?
        raise GameError, 'Route must include two non-port stops.' unless route.stops.size > 2
      end

      def sms_hexes
        NEW_SMS_HEXES
      end

      def self.title
        '1849: Kingdom of the Two Sicilies'
      end

      def num_trains(train)
        case train[:name]
        when '6H'
          4
        when '8H'
          4
        when '16H'
          6
        end
      end

      def stop_revenue(stop, phase, train)
        return gray_revenue(stop) if NEW_GRAY_REVENUE_CENTERS.keys.include?(stop.hex.id)

        stop.route_revenue(phase, train)
      end

      def gray_revenue(stop)
        NEW_GRAY_REVENUE_CENTERS[stop.hex.id][@phase.name]
      end

      def event_earthquake!
        @log << '-- Event: Avezzano Earthquake --'
        new_tile = Engine::Tile.from_code('C7', :gray, AVZ_CODE)
        new_tile.location_name = 'Avezzano'
        hex_by_id('C7').tile = new_tile
      end

      def remove_corp; end
    end
  end
end
