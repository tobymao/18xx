# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_18_chesapeake/game'

module Engine
  module Game
    module G18ChristmasEve
      class Game < G18Chesapeake::Game
        include_meta(G18ChristmasEve::Meta)

        BANK_CASH = 12_000

        SELL_BUY_ORDER = :sell_buy_sell

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, bank: :full_or }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          white: {
            %w[C8 D11 D3 D7 D9 E4 F5 F11 H11 I2 I4 I8 J5 J7 K4 K12 L1 L3 L9] => '',
            %w[G8 G10 H7 H9] => 'upgrade=cost:80,terrain:mountain',
            %w[B9 C4 C12 I12] => 'town=revenue:0',
            %w[B7 I6 J3] => 'town=revenue:0;town=revenue:0',
            %w[C10] => 'city=revenue:0;label=DC',
            %w[B3 D5 E6 E10 F3 F9 G12 K2 K8 K10 L5 L11] => 'city=revenue:0]',
          },
          red: {
            %w[E14] => 'offboard=revenue:yellow_20|green_40|brown_60|gray_80;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[L13] => 'offboard=revenue:yellow_20|green_80|gray_120;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[A8] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_60;path=a:4,b:_0',
            %w[J11] => 'city=revenue:20;path=a:1,b:_0',
            %w[A6] => 'offboard=revenue:20;path=a:5,b:_0',
            %w[K6] => 'offboard=revenue:20,groups:Bathroom;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0;border=edge:5',
            %w[L7] => 'offboard=revenue:20,hide:1,groups:Bathroom;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;border=edge:2',
            %w[A2] => 'offboard=revenue:yellow_60|brown_20|gray_10,groups:Back Door;path=a:5,b:_0;border=edge:4',
            %w[B1] => 'offboard=revenue:yellow_60|brown_20|gray_10,hide:1,groups:Back Door;path=a:0,b:_0;border=edge:1',
          },
          yellow: {
            %w[E12] => 'city=revenue:30;city=revenue:30;path=a:3,b:_0;path=a:0,b:_1;label=OO',
            %w[H3] => 'city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:5,b:_1;label=OO',
          },
          gray: {
            %w[D13 G4] => 'path=a:4,b:5',
            %w[F13 M12] => 'path=a:1,b:2',
            %w[B5] => 'path=a:0,b:3',
            %w[H13] => 'path=a:2,b:3',
            %w[G2] => 'path=a:1,b:5',
            %w[H5] => 'path=a:2,b:5;path=a:3,b:5',
            %w[B11] => 'town=revenue:yellow_20|brown_40;path=a:3,b:_0;path=a:4,b:_0',
            %w[F7] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
          }
        }.freeze

        LOCATION_NAMES = {
          'J11' => 'Basement',
          'E14' => 'Front Door',
          'B11' => 'Christmas Tree',
          'L13' => 'Balcony',
          'F7' => 'Bar',
          'L7' => 'Bathroom',
          'B1' => 'Back Door',
          'A6' => 'Forgotten Cupboard',
          'A8' => 'Garage',
        }.freeze

        def or_set_finished; end

        def timeline
          []
        end
      end
    end
  end
end
