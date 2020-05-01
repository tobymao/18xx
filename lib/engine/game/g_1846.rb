# File original exported from 18xx-maker: https://www.18xx-maker.com/
# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative 'base'

module Engine
  module Game
    class G1846 < Base
      BANK_CASH = {
        2 => 7000,
        3 => 6500,
        4 => 7500,
        5 => 9000,
      }.freeze

      CURRENCY_FORMAT_STR = '$%d'

      CERT_LIMIT = {
        2 => 19,
        3 => 14,
        4 => 12,
        5 => 11,
      }.freeze

      HEXES = {
        white: {
          %w[E5 F6 G5 H6 J4 B14 C11 C13 D8 D10 D12 E7 E9 E13 E15 E19 F4 F8 F10 F12 G11 H2 H4 H8 H10 I3 I7 I9 J8 D18 B10 B12 F14 F16 I11 J6] => 'blank',
          %w[B16 C9 D14 E11 G3 G7 G9 G13 G15] => 'city',
          %w[E17 H12] => 'c=r:0;l=Z',
          %w[F18 G17 H16] => 'u=c:40,t:mountain',
          %w[H14] => 'u=c:60,t:mountain',
        },
        gray: {
          %w[A15 C7] => 'p=a:4,b:5',
          %w[F20] => 'c=r:10;p=a:0,b:_0;p=a:1,b:_0;p=a:3,b:_0;p=a:4,b:_0',
          %w[I5] => 'c=r:10,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:5,b:_0',
          %w[I15] => 'c=r:20;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0',
          %w[K3] => 'c=r:20;p=a:2,b:_0',
        },
        red: {
          %w[B8] => 'o=r:yellow_40|brown_10;p=a:3,b:_0',
          %w[B18] => 'o=r:yellow_30|brown_50;p=a:0,b:_0;l=E',
          %w[C5] => 'o=r:yellow_20|brown_40;p=a:4,b:_0;l=W',
          %w[C17] => 'o=r:yellow_40|brown_60;p=a:0,b:_0;l=E',
          %w[C21] => 'o=r:yellow_30|brown_60;p=a:5,b:_0;l=E',
          %w[D22] => 'o=r:yellow_30|brown_60;p=a:0,b:_0;l=E',
          %w[E23 I17] => 'o=r:yellow_20|brown_50;p=a:0,b:_0;l=E',
          %w[F22] => 'o=r:yellow_30|brown_70;p=a:0,b:_0;l=E',
          %w[G21] => 'o=r:yellow_30|brown_70;p=a:0,b:_0;p=a:1,b:_0;l=E',
          %w[H20] => 'o=r:yellow_20|brown_40;p=a:1,b:_0;l=E',
          %w[I1] => 'o=r:yellow_50|brown_70;p=a:2,b:_0;p=a:3,b:_0;l=W',
          %w[J10] => 'o=r:yellow_50|brown_70;p=a:1,b:_0;p=a:2,b:_0',
        },
        yellow: {
          %w[C15] => 'c=r:40,s:2;p=a:0,b:_0;p=a:2,b:_0;l=Z;u=c:40,t:water',
          %w[D6] => 'c=r:10;c=r:10;c=r:10;c=r:10;p=a:2,b:_0;p=a:3,b:_1;p=a:4,b:_2;p=a:5,b:_3;l=Chi',
          %w[D20] => 'c=r:10,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:5,b:_0',
          %w[E21] => 'c=r:10;p=a:0,b:_0;p=a:1,b:_0;p=a:3,b:_0',
          %w[G19] => 'c=r:10;p=a:4,b:_0',
        },
        blue: {
          %w[C19 D16] => 'blank',
        }
      }.freeze

      TILES = {
        '5' => 3,
        '6' => 4,
        '7' => 5,
        '8' => 16,
        '9' => 16,
        '14' => 4,
        '15' => 5,
        '16' => 2,
        '17' => 1,
        '18' => 1,
        '19' => 2,
        '20' => 2,
        '21' => 1,
        '22' => 1,
        '23' => 4,
        '24' => 4,
        '25' => 2,
        '26' => 1,
        '27' => 1,
        '28' => 1,
        '29' => 1,
        '30' => 1,
        '31' => 1,
        '39' => 1,
        '40' => 1,
        '41' => 2,
        '42' => 2,
        '43' => 2,
        '44' => 1,
        '45' => 2,
        '46' => 2,
        '47' => 2,
        '51' => 2,
        '57' => 4,
        '70' => 1,
        '290' => 1,
        '291' => 1,
        '292' => 1,
        '293' => 1,
        '294' => 2,
        '295' => 2,
        '296' => 1,
        '297' => 2,
        '298' => 1,
        '299' => 1,
        '300' => 1,
        '611' => 4,
        '619' => 3,
      }.freeze

      LOCATION_NAMES = {
        'B8' => 'Holland',
        'B16' => 'Port Huron',
        'B18' => 'Sarnia',
        'C5' => 'Chicago Connections',
        'C9' => 'South Bend',
        'C15' => 'Detroit',
        'C17' => 'Windsor',
        'C21' => 'Buffalo',
        'D14' => 'Toledo',
        'D20' => 'ERIE',
        'D22' => 'Buffalo',
        'E11' => 'Fort Wayne',
        'E17' => 'Cleveland',
        'E21' => 'Salamanca',
        'E23' => 'Binghamton',
        'F22' => 'Pittsburgh',
        'G3' => 'Springfield',
        'G7' => 'Terre Haute',
        'G9' => 'Indianapolis',
        'G13' => 'Dayton',
        'G15' => 'Columbus',
        'G19' => 'Wheeling',
        'G21' => 'Pittsburgh',
        'H12' => 'Cincinnati',
        'H20' => 'Cumberland',
        'I1' => 'St. Louis',
        'I5' => 'Centralia',
        'I15' => 'Huntington',
        'I17' => 'Charleston',
        'J10' => 'Louisville',
        'K3' => 'Cairo',
      }.freeze

      # rubocop:disable Style/RedundantCapitalW, Lint/EmptyExpression, Lint/EmptyInterpolation
      MARKET = [
        %W[Closed 10 20 30 40p 50p 60p 70p 80p 90p 100p 112p 124p 137p 150p 165 180 195 212 230 250 270 295 320 345 375 405 440 475 510 550],
      ].freeze
      # rubocop:enable Style/RedundantCapitalW, Lint/EmptyExpression, Lint/EmptyInterpolation

      STARTING_CASH = {
        2 => 600,
        3 => 400,
        4 => 400,
        5 => 400,
      }.freeze

      PHASES = [
        {
          name: 'Yellow',
          operating_rounds: 2,
          train_limit: 4,
          tiles: :yellow,
          buy_companies: true,
        },
        {
          name: 'Green',
          operating_rounds: 2,
          train_limit: 3,
          tiles: %i[yellow green].freeze,
          buy_companies: true,
          on: ['3/5', '4'],
        },
        {
          name: 'Brown',
          operating_rounds: 2,
          train_limit: 2,
          tiles: %i[yellow green brown].freeze,
          on: ['4/6', '5'],
          events: { close_companies: true },
        },
        {
          name: 'Brown',
          operating_rounds: 2,
          train_limit: 2,
          tiles: %i[yellow green brown gray].freeze,
          on: ['6', '7/8'],
          events: { remove_tokens: true },
        },
      ].freeze

      TRAINS = [
        {
          name: '2',
          distance: 2,
          price: 80,
          num: 7,
        },
        {
          name: '3/5',
          distance: 3,
          price: 160,
          num: 6,
        },
        {
          name: '4',
          distance: 4,
          price: 180,
          num: 6,
        },
        {
          name: '4/6',
          distance: 4,
          price: 450,
          num: 5,
        },
        {
          name: '5',
          distance: 5,
          price: 500,
          num: 5,
        },
        {
          name: '6',
          distance: 6,
          price: 800,
          num: 9,
        },
        {
          name: '7/8',
          distance: 7,
          price: 900,
          num: 9,
        }
      ].freeze

      COMPANIES = [
        {
          name: 'Michigan Southern',
          value: '$60 + $80 Debt',
          revenue: 0,
          sym: 'MS',
          desc: 'Starts with $60 in treasury, a 2 train, and a token in Detroit (C15). Splits revenue evenly with owner.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Big 4',
          value: '$40 + $60 Debt',
          revenue: 0,
          sym: 'B4',
          desc: 'Starts with $60 in treasury, a 2 train, and a token in Indianapolis (G9). Splits revenue evenly with owner.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Chicago and Western Indiana',
          value: 60,
          revenue: 10,
          sym: 'CWI',
          desc: 'Reserves a token slot in Chicago (D6), in which the owning corporation may place an extra token at no cost.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Mail Contract',
          value: 80,
          revenue: 0,
          sym: 'MC',
          desc: 'Adds $10 per location visited by any one train of the owning corporation. Never closes once purchased by a corporation.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Tunnel Blasting Company',
          value: 60,
          revenue: 20,
          sym: 'TBC',
          desc: 'Reduces, for the owning corporation, the cost of laying all mountain tiles and tunnel/pass hexsides by $20.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Meat Packing Company',
          value: 60,
          revenue: 15,
          sym: 'MPC',
          desc: 'The owning corporation may place a $30 marker in either St. Louis (I1) or Chicago (D6), to add $30 to all routes run to this location.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Steamboat Company',
          value: 40,
          revenue: 10,
          sym: 'SC',
          desc: 'Place or shift the port marker among port locations (B8, C5, D14, G19, I1). Add $20 per port symbol to all routes run to this location by the owning (or assigned) company.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Lake Shore Line',
          value: 40,
          revenue: 15,
          sym: 'LSL',
          desc: 'The owning corporation may make an extra $0 cost tile upgrade of either Cleveland (E17) or Toledo (D14), but not both.',
          abilities: [
            # TODO
          ],
        },
        {
          name: 'Michigan Central',
          value: 40,
          revenue: 15,
          sym: 'MC',
          desc: 'The owning corporation may lay up to two extra $0 cost yellow tiles in the MC\'s reserved hexes (B10, B12).',
          abilities: [
            { type: :blocks_hex, hex: 'B10' },
            { type: :blocks_hex, hex: 'B12' },
            # TODO
          ],
        },
        {
          name: 'Ohio & Indiana',
          value: 40,
          revenue: 15,
          sym: 'O&I',
          desc: 'The owning corporation may lay up to two extra $0 cost yellow tiles in the O&I\'s reserved hexes (F14, F16).',
          abilities: [
            { type: :blocks_hex, hex: 'F14' },
            { type: :blocks_hex, hex: 'F16' },
            # TODO
          ],
        },
      ].freeze

      CORPORATIONS = [
        {
          sym: 'PRR',
          logo: '', # TODO
          name: 'Pennsylvania',
          tokens: [0, 80, 80, 80, 0],
          float_percent: 20,
          coordinates: 'F20',
          color: '#d1232a'
        },
        {
          sym: 'NYC',
          logo: '', # TODO
          name: 'New York Central',
          tokens: [0, 80, 80, 80],
          float_percent: 20,
          coordinates: 'D20',
          color: '#110a0c'
        },
        {
          sym: 'B&O',
          logo: '1846/BO',
          name: 'Baltimore & Ohio',
          tokens: [0, 80, 80, 0],
          float_percent: 20,
          coordinates: 'G19',
          color: '#025aaa'
        },
        {
          sym: 'C&O',
          logo: '1846/CO',
          name: 'Chesapeake & Ohio',
          tokens: [0, 80, 80, 80],
          float_percent: 20,
          coordinates: 'I15',
          color: ''
        },
        {
          sym: 'ERIE',
          logo: '', # TODO
          name: 'Erie',
          tokens: [0, 80, 80, 0],
          float_percent: 20,
          coordinates: 'E21',
          color: '#ffe600'
        },
        {
          sym: 'GT',
          logo: '', # TODO
          name: 'Grand Trunk',
          tokens: [0, 80, 80],
          float_percent: 20,
          coordinates: 'B16',
          color: '#f58121'
        },
        {
          sym: 'IC',
          logo: '', # TODO
          name: 'Illinois Central',
          tokens: [0, 80, 80, 0],
          float_percent: 20,
          coordinates: 'K3',
          color: '#32763f'
        }
      ].freeze
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
