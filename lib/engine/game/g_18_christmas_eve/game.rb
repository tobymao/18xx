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
            # Kitchen
            %w[D3 E4] => 'frame=color:#CE95C3',
            %w[B3 F3] => 'frame=color:#CE95C3;city=revenue:0',
            %w[C4] => 'frame=color:#CE95C3;town=revenue:0',
            # Dining
            %w[D5 E6] => 'frame=color:#F7FFB6;city=revenue:0',
            %w[D7 F5] => 'frame=color:#F7FFB6',
            # Lounge
            %w[C8 D9 D11] => 'frame=color:#FFFFFF',
            %w[B7] => 'frame=color:#FFFFFF;town=revenue:0;town=revenue:0',
            %w[B9 C12] => 'frame=color:#FFFFFF;town=revenue:0',
            %w[C10] => 'frame=color:#FFFFFF;city=revenue:0;label=DC',
            # Foyer
            %w[F11] => 'frame=color:#7D96CD',
            %w[E10] => 'frame=color:#7D96CD;city=revenue:0;',
            # Staircase
            %w[G8 G10 H7 H9] => 'upgrade=cost:80,terrain:mountain;frame=color:#C4E4CD',
            # Study
            %w[G12] => 'frame=color:#BBBBB6;city=revenue:0;',
            %w[H11] => 'frame=color:#BBBBB6;',
            %w[I12] => 'frame=color:#BBBBB6;town=revenue:0',
            # Master
            %w[K10 L11] => 'frame=color:#E6C4AF;city=revenue:0;',
            %w[L9 K12] => 'frame=color:#E6C4AF;',
            # Hall
            %w[I4 J5 I8 J7] => 'frame=color:#F5846B',
            %w[I6] => 'frame=color:#F5846B;town=revenue:0;town=revenue:0',
            %w[K8] => 'frame=color:#F5846B;city=revenue:0;',
            # Rec Room
            %w[I2 J1] => 'frame=color:#9FCAA1',
            %w[J3] => 'frame=color:#9FCAA1;town=revenue:0;town=revenue:0',
            # Bedroom
            %w[L1 L3] => 'frame=color:#AB9E7F',
            %w[K2] => 'frame=color:#AB9E7F;city=revenue:0;',
            # Bedroom
            %w[K4] => 'frame=color:#AFDFE0',
            %w[L5] => 'frame=color:#AFDFE0;city=revenue:0;',
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
            %w[E12] => 'frame=color:#7D96CD;city=revenue:30;city=revenue:30;path=a:3,b:_0;path=a:0,b:_1;label=OO',
            %w[H3] => 'frame=color:#F5846B;city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:5,b:_1;label=OO',
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

        CORPORATIONS = [
          {
            float_percent: 60,
            sym: 'PRR',
            name: 'Pennsylvania Railroad',
            logo: '18_chesapeake/PRR',
            simple_logo: '18_chesapeake/PRR.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'L11',
            color: '#237333',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'PLE',
            name: 'Pittsburgh and Lake Erie Railroad',
            logo: '18_chesapeake/PLE',
            simple_logo: '18_chesapeake/PLE.alt',
            tokens: [0, 40, 60],
            coordinates: 'B3',
            color: :black,
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'SRR',
            name: 'Strasburg Rail Road',
            logo: '18_chesapeake/SRR',
            simple_logo: '18_chesapeake/SRR.alt',
            tokens: [0, 40],
            city: 1,
            coordinates: 'E12',
            color: '#d81e3e',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'B&O',
            name: 'Baltimore & Ohio Railroad',
            logo: '18_chesapeake/BO',
            simple_logo: '18_chesapeake/BO.alt',
            tokens: [0, 40, 60],
            coordinates: 'L5',
            city: 0,
            color: '#0189d1',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'C&O',
            name: 'Chesapeake & Ohio Railroad',
            logo: '18_chesapeake/CO',
            simple_logo: '18_chesapeake/CO.alt',
            tokens: [0, 40, 60, 80],
            coordinates: 'K2',
            color: '#a2dced',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'LV',
            name: 'Lehigh Valley Railroad',
            logo: '18_chesapeake/LV',
            simple_logo: '18_chesapeake/LV.alt',
            tokens: [0, 40],
            coordinates: 'F9',
            color: '#FFF500',
            text_color: 'black',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'C&A',
            name: 'Camden & Amboy Railroad',
            logo: '18_chesapeake/CA',
            simple_logo: '18_chesapeake/CA.alt',
            tokens: [0, 40],
            coordinates: 'J11',
            color: '#f48221',
            reservation_color: nil,
          },
          {
            float_percent: 60,
            sym: 'N&W',
            name: 'Norfolk & Western Railway',
            logo: '18_chesapeake/NW',
            simple_logo: '18_chesapeake/NW.alt',
            tokens: [0, 40, 60],
            coordinates: 'E6',
            color: '#7b352a',
            reservation_color: nil,
          },
        ].freeze

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
          'G8' => 'Staircase',
          'D3' => 'Kitchen',
          'D7' => 'Dining',
          'H11' => 'Study',
          'C8' => 'Lounge',
          'L9' => 'Master',
          'J7' => 'Hall',
          'K4' => 'Bedroom',
          'L3' => 'Bedroom',
          'I2' => 'Rec Room',
          'F11' => 'Foyer',

        }.freeze

        def or_set_finished; end

        def timeline
          []
        end
      end
    end
  end
end
