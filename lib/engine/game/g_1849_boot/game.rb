# frozen_string_literal: true

require_relative '../g_1849/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1849Boot
      class Game < G1849::Game
        include_meta(G1849Boot::Meta)
        include G1849Boot::Entities
        include G1849Boot::Map

        CURRENCY_FORMAT_STR = 'L.%d'

        BANK_CASH = 7760

        CERT_LIMIT = { 3 => 19, 4 => 14, 5 => 12, 6 => 10 }.freeze

        STARTING_CASH = { 3 => 500, 4 => 375, 5 => 330, 6 => 300 }.freeze

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[72 83 95 107 120 133 147 164 182 202 224 248 276 306u 340u 377e],
          %w[63 72 82 93 104 116 128 142 158 175 195 216z 240 266u 295u 328u],
          %w[57 66 75 84 95 105 117 129 144x 159 177 196 218 242u 269u 298u],
          %w[54 62 71 80 90 100p 111 123 137 152 169 187 208 230],
          %w[52 59 68p 77 86 95 106 117 130 145 160 178 198],
          %w[47 54 62 70 78 87 96 107 118 131 146 162],
          %w[41 47 54 61 68 75 84 93 103 114 127],
          %w[34 39 45 50 57 63 70 77 86 95],
          %w[27 31 36 40 45 50 56],
          %w[0c 24 27 31],
        ].freeze

        PHASES = [
          {
            name: '4H',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['gray_uses_white'],
          },
          {
            name: '6H',
            on: '6H',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_white can_buy_companies],
          },
          {
            name: '8H',
            on: '8H',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '10H',
            on: '10H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_gray can_buy_companies],
          },
          {
            name: '12H',
            on: '12H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: ['gray_uses_black'],
          },
          {
            name: '16H',
            on: '16H',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
            status: %w[gray_uses_black blue_zone],
          },
        ].freeze

        TRAINS = [{ name: '4H', num: 4, distance: 4, price: 100, rusts_on: '8H' },
                  {
                    name: '6H',
                    num: 4,
                    distance: 6,
                    price: 200,
                    rusts_on: '10H',
                    events: [{ 'type' => 'green_par' }],
                  },
                  { name: '8H', num: 4, distance: 8, price: 350, rusts_on: '16H' },
                  {
                    name: '10H',
                    num: 3,
                    distance: 10,
                    price: 550,
                    events: [{ 'type' => 'brown_par' }],
                  },
                  {
                    name: '12H',
                    num: 1,
                    distance: 12,
                    price: 800,
                    events: [{ 'type' => 'close_companies' }, { 'type' => 'earthquake' }],
                  },
                  { name: '16H', num: 6, distance: 16, price: 1100 },
                  { name: 'R6H', num: 2, available_on: '16H', distance: 6, price: 600 }].freeze

        CORP_CHOOSES_HOME = 'SFR'
        CORP_CHOOSES_HOME_HEXES = %w[E11 H8 I13 I17 J18 K19 L12 L20 O9 P2].freeze
        NEW_PORT_HEXES = %w[B16 G5 J20 L16].freeze
        NEW_SMS_HEXES = %w[B14 G7 H8 J18 L12 L18 L20 N20 O9 P2].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          green_par: ['144 Par Available',
                      'Corporations may now par at 144 (in addition to 67 and 100)'],
          brown_par: ['216 Par Available',
                      'Corporations may now par at 216 (in addition to 67, 100, and 144)'],
          earthquake: ['Avezzano Earthquake',
                       'Avezzano (C7) loses connection to Rome, revenue reduced to 10.']
        ).freeze

        AVZ_CODE = 'town=revenue:10;path=a:4,b:_0,track:narrow'.freeze

        NEW_GRAY_REVENUE_CENTERS =
          {
            A7:
              {
                '4H': 10,
                '6H': 10,
                '8H': 40,
                '10H': 40,
                '12H': 60,
                '16H': 60,
              },
            N2:
             {
               '4H': 30,
               '6H': 30,
               '8H': 50,
               '10H': 50,
               '12H': 80,
               '16H': 80,
             },
            C5:
             {
               '4H': 60,
               '6H': 60,
               '8H': 90,
               '10H': 90,
               '12H': 120,
               '16H': 120,
             },
            J18:
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
            B14:
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
            I13:
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
            N20:
             {
               '4H': 20,
               '6H': 20,
               '8H': 30,
               '10H': 30,
               '12H': 40,
               '16H': 40,
             },
          }.freeze

        def check_other(route)
          return if (route.stops.map(&:hex).map(&:id) & NEW_PORT_HEXES).empty?
          raise GameError, 'Route must include two non-port stops.' unless route.stops.size > 2
        end

        def sms_hexes
          NEW_SMS_HEXES
        end

        def num_trains(train)
          fewer = @players.size < 5
          puts fewer
          case train[:name]
          when '6H' || '8H'
            fewer ? 3 : 4
          end
        end

        def stop_revenue(stop, phase, train)
          return gray_revenue(stop) if NEW_GRAY_REVENUE_CENTERS.key?(stop.hex.id)

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
end
