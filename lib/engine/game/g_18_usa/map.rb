# frozen_string_literal: true

module Engine
  module Game
    module G18USA
      module Map
        LAYOUT = :pointy

        YELLOW_PLAIN_TRACK_TILES = %w[7 8 9].freeze
        GREEN_PLAIN_TRACK_TILES = %w[80 81 82 83].freeze
        BROWN_PLAIN_TRACK_TILES = %w[544 545 546].freeze
        GRAY_PLAIN_TRACK_TILES = %w[X17 60].freeze
        PLAIN_TRACK_TILES = YELLOW_PLAIN_TRACK_TILES + GREEN_PLAIN_TRACK_TILES + BROWN_PLAIN_TRACK_TILES + GRAY_PLAIN_TRACK_TILES

        PLAIN_YELLOW_CITY_TILES = %w[5 6 57].freeze
        PLAIN_GREEN_CITY_TILES = %w[14 15 619].freeze
        PLAIN_BROWN_CITY_TILES = %w[63 611 448].freeze

        CITY_HEXES = %w[B8 B14 C3 C17 C29 D6 D14 D20 D24 E3 E7 E11 E15 E17 E23 F20 F26 G3 G7 G11 G17 G27 H8 H14 H20 H22 I13 I15
                        I19 I25].freeze
        OIL_HEXES = %w[B12 G15 H4 I17 I21 I23 J14].freeze
        IRON_HEXES = %w[B10 C7 C19 D16 E5 E9 G21 H6].freeze
        COAL_HEXES = %w[B6 B10 B12 C9 D8 D10 D26 E19 E25 F8 F10 F16 F22 F24].freeze
        BRIDGE_CITY_HEXES = %w[I19 C3 C17 D14 E15 E17 F20 G17].freeze
        BRIDGE_TILE_HEXES = %w[B4 D18 E21 F18 H18].freeze
        MEXICO_HEXES = %w[I5 I7 I9 I11 J12 K13].freeze

        METROPOLITAN_HEXES = %w[G3 E11 H14 H22 I19 D20].freeze
        SUBSIDIZED_HEXES = %w[B8 B14 C3 D6 D14 E3 E7 E23 G7 G11 G27 H8 I13 I25].freeze

        TILES = {
          '5' => 'unlimited',
          '6' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '57' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '592' => 'unlimited',
          '619' => 'unlimited',
          '63' => 'unlimited',
          '448' => 'unlimited',
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '593' => 'unlimited',
          '611' => 'unlimited',
          '597' => 'unlimited',
          '60' => 'unlimited',
          'X01' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=ATL',
          },
          'X02' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=CHI',
          },
          'X03' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DFW',
          },
          'X04' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DEN',
          },
          'X05' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=LA',
          },
          'X06' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=NO',
          },
          'X07' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R.J.',
          },
          'X08' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=R.J.',
          },
          'X09' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=R.J.',
          },
          'X10' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DFW',
          },
          'X11' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=LA',
          },
          'X12' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60,slots:2;city=revenue:60;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,'\
                      'b:_1;label=NY',
          },
          'X13' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=CL',
          },
          'X14' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'label=DFW',
          },
          'X15' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          'X16' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NY',
          },
          'X17' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
          },
          'X18' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=DFW',
          },
          'X19' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:90,slots:4;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          'X20' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C.T.',
          },
          'X21' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C.T.',
          },
          'X22' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C.T.',
          },
          'X23' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'X30' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY',
          },
        }.freeze

        LOCATION_NAMES = {
          'A15' => 'Winnipeg',
          'A27' => 'Montreal',
          'B2' => 'Seattle',
          'B8' => 'Helena',
          'B14' => 'Fargo',
          'C3' => 'Portland',
          'C17' => 'Minneapolis',
          'C23' => 'Detroit',
          'C25' => 'Toronto',
          'C29' => 'Boston',
          'D6' => 'Boise',
          'D14' => 'Omaha',
          'D20' => 'Chicago',
          'D24' => 'Cleveland',
          'D28' => 'New York City',
          'E1' => 'San Francisco',
          'E3' => 'Sacramento',
          'E7' => 'Salt Lake City',
          'E11' => 'Denver',
          'E15' => 'Kansas City',
          'E17' => 'St. Louis',
          'E23' => 'Columbus',
          'F20' => 'Louisville',
          'F26' => 'Baltimore',
          'G3' => 'Los Angeles',
          'G7' => 'Pheonix',
          'G11' => 'Santa Fe',
          'G17' => 'Memphis',
          'G27' => 'Norfolk',
          'H8' => 'Tucson',
          'H14' => 'Dallas-Fort Worth',
          'H20' => 'Birmingham',
          'H22' => 'Atlanta',
          'I13' => 'San Antonio',
          'I15' => 'Houston',
          'I19' => 'New Orelans',
          'I25' => 'Jacksonville',
          'J20' => 'Port of New Orleans',
          'J24' => 'Florida',
          'I9' => 'Mexico',
        }.freeze

        HEXES = {
          white: {
            %w[B20 B26 C5 C11 C13 C15 D2 D4 D12 D22 E13 F2 F6 F12 F14 G9 G13 G19 G25 H10 H12 H16
               H24 H26] => '',
            %w[E27] => 'stub=edge:3',
            %w[E11 G3 H14 I15 H20 H22 F26 C29 D24] => 'city=revenue:0',
            %w[D6 E3 E7 G7 G11 H8 I13 I25 G27 E23] => 'city=revenue:0;icon=image:18_ms/coins',
            %w[C17 E15 E17 F20 G17 I19] => 'city=revenue:0;upgrade=cost:10,terrain:water;icon=image:18_usa/bridge',
            %w[C3
               D14] => 'city=revenue:0;upgrade=cost:10,terrain:water;icon=image:18_ms/coins;icon=image:18_usa/bridge',
            %w[B28 C27 F4 G5 G23] => 'upgrade=cost:15,terrain:mountain',
            %w[D18 E21 F18 H18] => 'upgrade=cost:10,terrain:water',
            ['B22'] => 'upgrade=cost:20,terrain:lake',
            %w[C7 E9 G21] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/mine',
            %w[D16 E5 H6] => 'icon=image:18_usa/mine',
            %w[G15 H4 I17 I21 I23 J14] => 'icon=image:18_usa/oil-derrick',
            %w[E19 F16] => 'icon=image:18_usa/coalcar',
            %w[C9 D8 D10 E25 F8 F10 F22 F24] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar',
            %w[D26] => 'upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar;stub=edge:4',
            %w[B16 B18] => 'icon=image:18_usa/gnr',
            ['C19'] => 'icon=image:18_usa/gnr;icon=image:18_usa/mine',
            ['B10'] => 'icon=image:18_usa/gnr;icon=image:18_usa/coalcar;icon=image:18_usa/mine',
            ['B12'] => 'icon=image:18_usa/gnr;icon=image:18_usa/coalcar;icon=image:18_usa/oil-derrick',
            ['D20'] => 'icon=image:18_usa/gnr;city=revenue:0',
            %w[B8 B14] => 'icon=image:18_usa/gnr;city=revenue:0;icon=image:18_ms/coins',
            ['B6'] => 'icon=image:18_usa/gnr;upgrade=cost:15,terrain:mountain;icon=image:18_usa/coalcar',
            ['B4'] => 'icon=image:18_usa/gnr;upgrade=cost:10,terrain:water',
          },
          gray: {
            ['B30'] => 'path=a:1,b:0',
            ['C23'] => 'town=revenue:yellow_30|green_40|brown_50|gray_60;path=a:4,b:_0;path=a:2,b:_0;path=a:0,b:_0',
            ['C25'] => 'town=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          yellow: {
            ['D28'] => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_1;path=a:3,b:_0;label=NY',
          },
          blue: {
            ['F28'] => 'offboard=revenue:yellow_0,visit_cost:99;path=a:0,b:_0',
            %w[B24 C21] => '',
          },
        }.freeze
      end
    end
  end
end
