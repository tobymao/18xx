# frozen_string_literal: true

module Engine
  module Game
    module G1848
      module Map
        LAYOUT = :pointy
        TILES = {
          '1' => 1,
          '2' => 1,
          '5' => 3,
          '6' => 4,
          '7' => 4,
          '8' => 9,
          '9' => 12,
          '14' => 3,
          '15' => 6,
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 3,
          '59' => 2,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '70' => 1,
          '235' => 3,
          '236' => 2,
          '237' => 1,
          '238' => 1,
          '239' => 3,
          '240' => 2,
          '241' => {
            'count' => 1,
            'color' => 'blue',
            'code' => 'offboard=revenue:50;icon=image:anchor;path=a:2,b:_0;path=a:1,b:_0',
          },
          '611' => 4,
          '915' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Alice Springs',
          'A6' => 'Alice Springs',
          'A18' => 'Cairns',
          'D1' => 'Perth',
          'F3' => 'Port Lincoln',
          'B17' => 'Toowoomba & Ipswich',
          'B19' => 'Brisbane',
          'F17' => 'Sydney',
          'G14' => 'Canberra',
          'H11' => 'Melbourne',
          'E4' => 'Port Augusta',
          'G6' => 'Adelaide',
          'C20' => 'Southport',
          'E18' => 'Newcastle',
          'E14' => 'Dubbo',
          'F13' => 'Wagga Wagga',
          'D9' => 'Broken Hill',
          'H9' => 'Geelong',
          'H7' => 'Mount Gambier',
          'F5' => 'Port Pirie',
          'E2' => 'Whyalla',
          'F15' => 'Orange & Bathurst',
          'G10' => 'Ballarat & Bendigo',
          'G16' => 'Wollongong',
          'I21' => 'BOE Payout',
        }.freeze

        GHAN_HEXES = %w[A4 A6].freeze

        HEXES = {
          red: {
            ['A4'] =>
                     'offboard=revenue:yellow_10|green_20|brown_40|gray_60;path=a:5,b:_0;path=a:0,b:_0;border=edge:4',
            ['A6'] =>
                   'offboard=revenue:yellow_10|green_20|brown_40|gray_60;path=a:5,b:_0;path=a:0,b:_0;border=edge:1',
            ['A18'] =>
                   'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:5,b:_0;path=a:0,b:_0',
            ['D1'] =>
                   'city=revenue:yellow_20|green_40|brown_60|gray_80;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=K',
            ['I21'] => 'offboard=revenue:yellow_0|green_100|brown_200|gray_300'
          },
          blue: {
            ['B21'] =>
                     'offboard=revenue:yellow_10|green_10|brown_20|gray_20;path=a:0,b:_0',
            ['F3'] =>
            'offboard=revenue:yellow_10|green_10|brown_20|gray_20;path=a:2,b:_0',
          },
          darkblue: {
            %w[I8 I10] => '',
          },
          white: {
            %w[B11 B13 B15 B5 D5 E12] => '',
            %w[B3 C2 C4] => 'upgrade=cost:40,terrain:desert',
            %w[B19 F17 H11] => 'city=revenue:0;label=K',
            %w[E4 E18 E14 F5 E2] => 'city=revenue:0',
            ['D3'] => 'town=revenue:0;town=revenue:0',
            ['B17'] => 'city=revenue:0;city=revenue:0',
            ['B7'] => 'upgrade=cost:40,terrain:desert;'\
                      'border=edge:4,type:mountain;border=edge:5,type:mountain',
            ['B9'] => 'upgrade=cost:40,terrain:desert;border=edge:1,type:mountain',
            ['C6'] => 'border=edge:4,type:mountain',
            ['C8'] => 'upgrade=cost:40,terrain:desert;' \
                      'border=edge:0,type:mountain;border=edge:5,type:mountain;' \
                      'border=edge:1,type:mountain;border=edge:2,type:mountain',
            %w[C10 C12 C14 C16] => 'border=edge:0,type:mountain;border=edge:5,type:mountain',
            ['C18'] => 'town=revenue:0;town=revenue:0;upgrade=cost:50,terrain:mountain;'\
                       'border=edge:0,type:mountain;border=edge:5,type:mountain',
            %w[C20 F13] => 'city=revenue:0;border=edge:0,type:mountain',
            %w[D7 F7] => 'border=edge:3,type:mountain;border=edge:4,type:mountain;'\
                         'border=edge:5,type:mountain;',
            ['D9'] => 'city=revenue:0;border=edge:1,type:mountain;' \
                      'border=edge:2,type:mountain;border=edge:3,type:mountain',
            %w[D19 D15 D13 D11] => 'border=edge:2,type:mountain;border=edge:3,type:mountain;',
            ['D17'] => 'upgrade=cost:50,terrain:mountain;' \
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
            ['E6'] => 'upgrade=cost:40,terrain:desert;border=edge:4,type:mountain',
            ['E8'] => 'upgrade=cost:40,terrain:desert;' \
                      'border=edge:0,type:mountain;border=edge:1,type:mountain;' \
                      'border=edge:2,type:mountain;border=edge:5,type:mountain',
            ['E10'] => 'border=edge:0,type:mountain',
            ['E16'] => 'upgrade=cost:50,terrain:mountain',
            ['F9'] => 'border=edge:1,type:mountain;border=edge:2,type:mountain;' \
                      'border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['F11'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;' \
                       'border=edge:5,type:mountain',
            ['F15'] => 'city=revenue:0;city=revenue:0;upgrade=cost:50,terrain:mountain',
            ['G6'] => 'city=revenue:0;label=K;border=edge:4,type:mountain;',
            ['G8'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;' \
                      'border=edge:2,type:mountain',
            ['G10'] => 'city=revenue:0;city=revenue:0;border=edge:3,type:mountain',
            ['G12'] => 'town=revenue:0;town=revenue:0;border=edge:2,type:mountain;' \
                       'border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['G14'] => 'city=revenue:0;border=edge:0,type:mountain;border=edge:5,type:mountain;'\
                       'city=revenue:0;border=edge:1,type:mountain',
            ['G16'] => 'city=revenue:0;upgrade=cost:50,terrain:mountain;border=edge:0,type:mountain',
            ['H7'] => 'city=revenue:0;border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['H9'] => 'city=revenue:0;border=edge:1,type:mountain',
            ['H13'] => 'upgrade=cost:50,terrain:mountain;border=edge:3,type:mountain',
            ['H15'] => 'upgrade=cost:50,terrain:mountain;' \
                       'border=edge:2,type:mountain;border=edge:3,type:mountain',
          },
        }.freeze
      end
    end
  end
end
