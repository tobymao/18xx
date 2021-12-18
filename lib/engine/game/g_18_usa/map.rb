# frozen_string_literal: true

module Engine
  module Game
    module G18USA
      module Map
        LAYOUT = :pointy

        YELLOW_PLAIN_TRACK_TILES = %w[
          7 7coal 7iron10 7iron20 7oil
          8 8coal 8iron10 8iron20 8oil
          9 9coal 9iron10 9iron20 9oil
        ].freeze

        GREEN_PLAIN_TRACK_TILES = %w[
          80 80coal 80oil
          81 81coal 81oil
          82 82coal 82oil
          83 83coal 83oil
        ].freeze
        BROWN_PLAIN_TRACK_TILES = %w[
          544 544coal 544oil
          545 545coal 545oil
          546 546coal 546oil
        ].freeze
        GRAY_PLAIN_TRACK_TILES = %w[
          X17coal X17oil X17
          60 60coal 60oil
        ].freeze
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
          '6' => 'unlimited',
          '5' => 'unlimited',
          '7' => 'unlimited',
          '8' => 'unlimited',
          '9' => 'unlimited',
          '14' => 'unlimited',
          '15' => 'unlimited',
          '57' => 'unlimited',
          '60' => 'unlimited',
          '63' => 'unlimited',
          '80' => 'unlimited',
          '81' => 'unlimited',
          '82' => 'unlimited',
          '83' => 'unlimited',
          '448' => 'unlimited',
          '544' => 'unlimited',
          '545' => 'unlimited',
          '546' => 'unlimited',
          '592' => 'unlimited',
          '593' => 'unlimited',
          '597' => 'unlimited',
          '611' => 'unlimited',
          '619' => 'unlimited',
          '7coal' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:1;label=⛏️',
          },
          '8coal' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:2;label=⛏️',
          },
          '9coal' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:3;label=⛏️',
          },
          '544coal' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '545coal' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=⛏️',
          },
          '546coal' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '80coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=⛏️',
          },
          '81coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '82coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;label=⛏️',
          },
          '83coal' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:10,hide:1;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=⛏️',
          },
          '60coal' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:10,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=⛏️',
          },
          'X17coal' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:10,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=⛏️',
          },
          '7iron10' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:1;label=⚒️',
          },
          '8iron10' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:2;label=⚒️',
          },
          '9iron10' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:10,hide:1;path=a:0,b:3;label=⚒️',
          },
          '7iron20' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'offboard=revenue:20,hide:1;path=a:0,b:1;label=⚒️',
          },
          '8iron20' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'offboard=revenue:20,hide:1;path=a:0,b:2;label=⚒️',
          },
          '9iron20' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'offboard=revenue:20,hide:1;path=a:0,b:3;label=⚒️',
          },
          '7oil' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:1;label=🛢️',
          },
          '8oil' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:2;label=🛢️',
          },
          '9oil' =>
          {
            'count' => 'unlimited',
            'color' => 'yellow',
            'code' => 'offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:3;label=🛢️',
          },
          '544oil' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=🛢️',
          },
          '545oil' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=🛢️',
          },
          '546oil' =>
          {
            'count' => 'unlimited',
            'color' => 'brown',
            'code' => 'junction;offboard=revenue:20,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=🛢️',
          },
          '80oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=🛢️',
          },
          '81oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=🛢️',
          },
          '82oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;label=🛢️',
          },
          '83oil' =>
          {
            'count' => 'unlimited',
            'color' => 'green',
            'code' => 'junction;offboard=revenue:yellow_10|brown_20,hide:1;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0;label=🛢️',
          },
          '60oil' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:20,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=🛢️',
          },
          'X17oil' =>
          {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;offboard=revenue:20,hide:1;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=🛢️',
          },
          'RuralK' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R.J.',
          },
          'RuralY' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=R.J.',
          },
          'RuralX' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=R.J.',
          },
          'CTownK' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=C.T.',
          },
          'CTownY' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C.T.',
          },
          'CTownX' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:yellow_30|green_40|brown_50,slots:1;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=C.T.',
          },
          'RHQ4' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'RHQ5' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'RHQ6' =>
          {
            'count' => 1,
            'color' => 'blue',
            'code' => 'city=slots:3,revenue:50;label=RHQ;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'ATL1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'CHI1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'NO1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=B',
          },
          'D0' => {
            'count' => 1,
            'color' => 'white',
            'code' => 'city=revenue:0;label=D',
          },
          'D1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=D',
          },
          'D2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=slots:2,revenue:50;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=D',
          },
          'D3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=slots:3,revenue:60;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=D',
          },
          'D4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=slots:3,revenue:80;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=D',
          },
          'DFW1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DFW',
          },
          'LA1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=LA',
          },
          'DFW2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=DFW',
          },
          'LA2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=LA',
          },
          'NY2' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:60,slots:2;city=revenue:60;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,'\
                      'b:_1;label=NY',
          },
          'CL' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=CL',
          },
          'DFW3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'label=DFW',
          },
          'LA3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          'NY3' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=NY',
          },
          'X17' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'junction;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;',
          },
          'DFW4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=DFW',
          },
          'LA4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:90,slots:4;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=LA',
          },
          'NY4' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100,slots:4;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=NY',
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
      end
    end
  end
end
