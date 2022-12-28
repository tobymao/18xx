# frozen_string_literal: true

module Engine
  module Game
    module G18BF
      module Map
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze

        LOCATION_NAMES = {
          'A9' => 'Perth',
          'A11' => 'Dundee',
          'A13' => 'Aberdeen',
          'C5' => 'Dumbarton',
          'C7' => 'Stirling',
          'C11' => 'Kirkcaldy',
          'D4' => 'Greenock',
          'D6' => 'Glasgow',
          'D8' => 'Falkirk',
          'D10' => 'Edinburgh',
          'E15' => 'Berwick',
          'F4' => 'Ayr',
          'G17' => 'Newcastle',
          'H2' => 'North Ireland',
          'H12' => 'Carlisle',
          'H16' => 'Durham',
          'H18' => 'Sunderland',
          'I17' => 'Darlington',
          'I19' => 'Middlesbrough',
          'K19' => 'York',
          'L12' => 'Preston',
          'L14' => 'Blackburn',
          'L16' => 'Leeds',
          'L22' => 'Hull',
          'M11' => 'Liverpool',
          'M13' => 'St Helens',
          'M15' => 'Manchester',
          'M17' => 'Sheffield',
          'M19' => 'Doncaster',
          'N4' => 'Mid-Ireland',
          'O13' => 'Crewe',
          'O15' => 'Stoke-on-Trent',
          'O17' => 'Derby',
          'O19' => 'Nottingham',
          'P14' => 'Wolverhampton',
          'P18' => 'Leicester',
          'P28' => 'Norwich',
          'Q15' => 'Birmingham',
          'Q17' => 'Coventry',
          'Q23' => 'Peterborough',
          'R14' => 'Worcester',
          'R20' => 'Northampton',
          'R24' => 'Cambridge',
          'R28' => 'Ipswich',
          'S3' => 'South Ireland',
          'S27' => 'Colchester',
          'S29' => 'Harwich',
          'T10' => 'Merthyr Tydfil',
          'T14' => 'Gloucester',
          'U7' => 'Swansea',
          'U9' => 'Rhondda',
          'U11' => 'Cardiff',
          'U13' => 'Bristol',
          'U17' => 'Swindon',
          'U19' => 'Reading',
          'U23' => 'London',
          'U27' => 'Southend',
          'V14' => 'Bath',
          'V22' => 'Guilford',
          'V26' => 'Chatham',
          'V28' => 'Canterbury',
          'V30' => 'Dover',
          'X8' => 'Plymouth',
          'X16' => 'Bournemouth',
          'X18' => 'Southampton',
          'X20' => 'Portsmouth',
          'X24' => 'Brighton',
          'L28' => 'London',
          'J6' => 'Crossing England–Scotland border',
          'L6' => 'Crossing England–Wales border',
          'G28' => 'Mine bonus',
          'I28' => 'London to red area',
        }.freeze

        HEXES = {
          white: {
            # Plain hexes.
            %w[B8 B10 E7 E9 F8 F16 G3 G15 H4 H6 I13 I21 J10 J12 J16 J18 J20 J22 K11 K17
               K21 K23 L10 L18 M23 N8 N14 N18 N20 N22 N24 O5 O21 O23 O27 O29
               P4 P6 P16 P20 P22 P24 P26 P30 Q7 Q13 Q19 Q21 Q25 Q27 Q29 R6 R16
               R18 R22 R26 R30 S5 S13 S15 S17 S19 S21 S23 S25 T6 T16 T18 T20
               T26 T28 U15 V16 V18 V20 W9 W11 W13 W15 W17 W19 W21 W23 W25 W27 W29
               X10 X12 X14 X22 X26] => '',
            %w[A5 A7 B4 B6 E11 F6 F10 G5 G7 H14 I15 J14 K13 K15 N16 P8 R8 S7 T8] => 'upgrade=cost:40,terrain:mountain',
            %w[I11 O7] => 'upgrade=cost:80,terrain:mountain',
            %w[C9] => 'border=edge:0,type:water,cost:80;border=edge:5,type:water,cost:80',
            %w[D12] => 'border=edge:2,type:impassable',
            %w[D14] => 'border=edge:5,type:province',
            %w[E3] => 'border=edge:5,type:impassable',
            %w[E5] => 'stub=edge:3',
            %w[E13 F12] => 'upgrade=cost:40,terrain:mountain;' \
                           'border=edge:4,type:province;border=edge:5,type:province',
            %w[G9] => 'border=edge:5,type:province;border=edge:5,type:water,cost:80',
            %w[F14 G13] => 'border=edge:1,type:province;border=edge:2,type:province',
            %w[G11] => 'border=edge:0,type:province;border=edge:0,type:water,cost:80;' \
                       'border=edge:4,type:province;border=edge:5,type:province',
            %w[H8] => 'border=edge:4,type:impassable;border=edge:5,type:impassable',
            %w[H10] => 'border=edge:1,type:impassable;' \
                       'border=edge:2,type:province;border=edge:2,type:water,cost:80;' \
                       'border=edge:3,type:province;border=edge:3,type:water,cost:80',
            %w[I9 V12] => 'border=edge:2,type:impassable',
            %w[L20 M21] => 'upgrade=cost:20,terrain:water',
            %w[N6] => 'upgrade=cost:40,terrain:water',
            %w[N10] => 'border=edge:4,type:impassable;border=edge:5,type:province',
            %w[N12] => 'upgrade=cost:20,terrain:water;border=edge:1,type:impassable',
            %w[O9 S9] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:province',
            %w[O11 Q11 S11] => 'border=edge:0,type:province;border=edge:1,type:province;' \
                               'border=edge:2,type:province',
            %w[P10 R10] => 'upgrade=cost:40,terrain:mountain;border=edge:3,type:province;' \
                           'border=edge:4,type:province;border=edge:5,type:province',
            %w[P12 R12] => 'border=edge:1,type:province',
            %w[Q9] => 'border=edge:4,type:province',
            %w[T4] => 'border=edge:5,type:impassable',
            %w[T12] => 'border=edge:0,type:province;border=edge:1,type:province;' \
                       'border=edge:5,type:water,cost:80',
            %w[T22] => 'stub=edge:5',
            %w[T24] => 'stub=edge:0',
            %w[U5] => 'border=edge:2,type:impassable',
            %w[U21] => 'upgrade=cost:20,terrain:water;stub=edge:4',
            %w[U25] => 'border=edge:0,type:water,cost:80;' \
                       'stub=edge:1;' \
                       'border=edge:5,type:water,cost:80',
            %w[V24] => 'stub=edge:2;' \
                       'border=edge:3,type:water,cost:80',

            # Town hexes.
            %w[C7 H16 I17 M13 M19 O13 O15 P18 Q17 Q23 R20 R24 S27 U17 U19 X16] => 'town=revenue:0',
            %w[A11] => 'town=revenue:0;border=edge:0,type:water,cost:80',
            %w[C5] => 'town=revenue:0;border=edge:0,type:water,cost:80;stub=edge:5',
            %w[D8] => 'town=revenue:0;border=edge:3,type:water,cost:80',
            %w[E15] => 'town=revenue:0;border=edge:1,type:province;border=edge:2,type:province',
            %w[F4] => 'town=revenue:0;border=edge:2,type:impassable',
            %w[H12] => 'town=revenue:0;border=edge:2,type:province',
            %w[L14] => 'town=revenue:0;stub=edge:5',
            %w[R14] => 'town=revenue:0;stub=edge:3',
            %w[T10] => 'town=revenue:0;upgrade=cost:40,terrain:mountain;' \
                       'border=edge:3,type:province;border=edge:4,type:province',
            %w[T14] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[U27] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable',
            %w[V22] => 'town=revenue:0;stub=edge:3',
            %w[V28] => 'town=revenue:0;border=edge:2,type:impassable',

            # City hexes.
            %w[A9 K19 L12 O17 P28 R28 U7 V14 X20 X24] => 'city=revenue:0',
            %w[D4] => 'city=revenue:0;border=edge:3,type:water,cost:80',
            %w[H18] => 'city=revenue:0;border=edge:5,type:water,cost:80',
            %w[I19] => 'city=revenue:0;border=edge:2,type:water,cost:80',
            %w[U11] => 'city=revenue:0;border=edge:3,type:province;' \
                       'border=edge:4,type:province;border=edge:4,type:water,cost:80;' \
                       'border=edge:5,type:impassable',
            %w[V26] => 'city=revenue:0;border=edge:2,type:water,cost:80;border=edge:3,type:impassable',

            # Y city hexes.
            %w[G17 O19 P14 U9 X18] => 'city=revenue:0;label=Y',
            %w[D10] => 'city=revenue:0;label=Y;border=edge:2,type:water,cost:80;border=edge:3,type:impassable',
            %w[C11] => 'city=revenue:0;label=Y;border=edge:0,type:impassable;border=edge:5,type:impassable',
            %w[M17] => 'city=revenue:0;label=Y;border=edge:1,type:mountain,cost:40',
            %w[U13] => 'city=revenue:0;label=Y;border=edge:1,type:province;' \
                       'border=edge:1,type:water,cost:80;border=edge:2,type:water,cost:80',
          },
          yellow: {
            %w[D6 Q15] => 'city=revenue:30;city=revenue:30;city=revenue:30;label=BGM;' \
                          'path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2',
            %w[L16] => 'city=revenue:30;city=revenue:30;city=revenue:30;label=BGM;' \
                       'path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;' \
                       'border=edge:0,type:mountain,cost:40',
            %w[M15] => 'city=revenue:30;city=revenue:30;city=revenue:30;label=BGM;' \
                       'path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;' \
                       'border=edge:3,type:mountain,cost:40;' \
                       'border=edge:4,type:mountain,cost:40',
            %w[M11] => 'city=revenue:30;city=revenue:30;label=L;path=a:3,b:_0;path=a:5,b:_1',
            %w[U23] => 'offboard=revenue:40;' \
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;' \
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          red: {
            %w[A13] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0',
            %w[H2] => 'offboard=revenue:yellow_20|green_20|brown_30|gray_40;' \
                      'path=a:3,b:_0;path=a:4,b:_0',
            %w[L22] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;' \
                       'path=a:1,b:_0;path=a:2,b:_0',
            %w[N4] => 'offboard=revenue:yellow_20|green_20|brown_30|gray_40;path=a:4,b:_0',
            %w[S3] => 'offboard=revenue:yellow_20|green_20|brown_30|gray_40;' \
                      'path=a:4,b:_0;path=a:5,b:_0',
            %w[S29] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;' \
                       'path=a:1,b:_0;path=a:2,b:_0',
            %w[V30] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;' \
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            %w[X8] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;' \
                      'path=a:3,b:_0;path=a:4,b:_0',
          },
          blue: {
            %w[B12] => 'path=a:0,b:1;path=a:2,b:5,terminal:2,ignore:1',
            %w[C13] => 'path=a:1,b:4,terminal:2,ignore:1',
          },
          gray: {
            %w[U29] => 'path=a:0,b:5',
            %w[V10] => 'path=a:2,b:3',

            # Supersized London hex.
            %w[L28] => 'offboard=revenue:0;border=edge:0;border=edge:1;' \
                       'border=edge:2;border=edge:3;border=edge:4;border=edge:5',
            %w[K27] => 'city=revenue:40,groups:London,hide:1,loc:0;' \
                       'city=revenue:40,groups:London,hide:1,loc:4;' \
                       'path=a:2,b:_0;path=a:2,b:_1;' \
                       'border=edge:0;border=edge:4;border=edge:5',
            %w[K29] => 'city=revenue:40,groups:London,hide:1,loc:1;' \
                       'city=revenue:40,groups:London,hide:1,loc:5;' \
                       'path=a:3,b:_0;path=a:3,b:_1;' \
                       'border=edge:0;border=edge:1;border=edge:5',
            %w[L26] => 'city=revenue:40,groups:London,hide:1,loc:3;' \
                       'city=revenue:40,groups:London,hide:1,loc:5;' \
                       'path=a:1,b:_0;path=a:1,b:_1;' \
                       'border=edge:3;border=edge:4;border=edge:5',
            %w[L30] => 'city=revenue:40,groups:London,hide:1,loc:0;' \
                       'city=revenue:40,groups:London,hide:1,loc:2;' \
                       'path=a:4,b:_0;path=a:4,b:_1;' \
                       'border=edge:0;border=edge:1;border=edge:2',
            %w[M27] => 'city=revenue:40,groups:London,hide:1,loc:2;' \
                       'city=revenue:40,groups:London,hide:1,loc:4;' \
                       'path=a:0,b:_0;path=a:0,b:_1;' \
                       'border=edge:2;border=edge:3;border=edge:4',
            %w[M29] => 'city=revenue:40,groups:London,hide:1,loc:1;' \
                       'city=revenue:40,groups:London,hide:1,loc:3;' \
                       'path=a:5,b:_0;path=a:5,b:_1;' \
                       'border=edge:1;border=edge:2;border=edge:3',

            # Legends showing bonuses.
            %w[J6] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40',
            %w[L6] => 'offboard=revenue:yellow_10|green_20|brown_20|gray_30',
            %w[G28] => 'offboard=revenue:yellow_0|green_0|brown_50|gray_60',
            %w[I28] => 'offboard=revenue:yellow_20|green_20|brown_30|gray_30',
          },
        }.freeze

        # For calculating whether routes cross borders, these are the hexes
        # with cities, towns or off-board areas in Scotland and Wales. All
        # revenue centres in other hexes are in England.
        SCOTTISH_REVENUE_CENTRES = %w[A9 A11 A13 C5 C7 C11 D4 D6 D8 D10 F4 H2].freeze
        WELSH_REVENUE_CENTRES = %w[N4 S3 T10 U7 U9 U11].freeze

        # London has twelve token slots (six cities with two slots each). This
        # is too many to render correctly, so an expanded view of London is
        # generated, with one hex for each of the six cities. To allow routes
        # to work we need to remap hex neighbours so that routes into London go
        # to these expanded hexes. These definitions give the hex edges to be
        # joined together.
        LONDON_HEX_NEIGHBOURS = [
          { coord1: 'M27', edge1: 0, coord2: 'V22', edge2: 3 },
          { coord1: 'L26', edge1: 1, coord2: 'U21', edge2: 4 },
          { coord1: 'K27', edge1: 2, coord2: 'T22', edge2: 5 },
          { coord1: 'K29', edge1: 3, coord2: 'T24', edge2: 0 },
          { coord1: 'L30', edge1: 4, coord2: 'U25', edge2: 1 },
          { coord1: 'M29', edge1: 5, coord2: 'V24', edge2: 2 },
        ].freeze
        LONDON_HEX_CENTRE = 'L28'

        def setup_london_hexes
          # Join the hexes adjacent to London to the expanded hexes.
          LONDON_HEX_NEIGHBOURS.each do |coord1:, edge1:, coord2:, edge2:|
            hex1 = @hexes.find { |hex| hex.coordinates == coord1 }
            hex2 = @hexes.find { |hex| hex.coordinates == coord2 }
            hex1.neighbors[edge1] = hex2
            hex2.neighbors[edge2] = hex1
          end

          # Sever all connections from the London hex on the main map.
          london = @hexes.find { |hex| hex.coordinates == LONDON_HEX_CENTRE }
          london.neighbors.clear
        end
      end
    end
  end
end
