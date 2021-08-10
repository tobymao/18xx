# frozen_string_literal: true

module Engine
  module Game
    module G1825
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
          # unit 3
          'B8' => 'Inverness',
          'B12' => 'Aberdeen',
          'C7' => 'Pitlochry',
          'D10' => 'Montrose',
          'E1' => 'Oban',
          'E7' => 'Perth',
          'E9' => 'Dundee',
          'F2' => 'Helensburgh & Gourock',
          'F4' => 'Dumbarton',
          'F6' => 'Stirling',
          'F8' => 'Dunfermline & Kirkaldy',
          'F10' => 'Anstruther',
          'G3' => 'Greenock',
          'G5' => 'Glasgow',
          'G7' => 'Coatbridge & Airdrie',
          'G9' => 'Edinburgh & Leith',
          'H4' => 'Kilmarnock & Ayr',
          'H6' => 'Motherwell',
          'J2' => 'Stranraer',
          'J6' => 'Dumfries',
          'J10' => 'Carlisle',
          'J14' => 'Newcastle upon Tyne & Sunderland',
          'K7' => 'Maryport',
          'K13' => 'Durham',
          'K15' => 'Stockton on Tees & Middlesbrough',
          # unit 2
          'L14' => 'Darlington',
          'L18' => 'Scarborough',
          'M9' => 'Barrow & Morecombe',
          'M15' => 'Harrogate & York',
          'N10' => 'Preston',
          'N12' => 'Burnley & Halifax',
          'N14' => 'Bradford & Leeds',
          'N18' => 'Hull',
          'O9' => 'Liverpool',
          'O11' => 'Manchester',
          'O15' => 'Barnsley & Doncaster',
          'P16' => 'Sheffield & Rotherham',
          'P18' => 'Lincoln',
          'Q11' => 'Crewe',
          'Q13' => 'Newcastle & Hanley',
          'Q15' => 'Derby',
          'Q17' => 'Nottingham',
          # unit 1
          'R10' => 'Shrewsbury',
          'R12' => 'Wolverhampton & Walsall',
          'R16' => 'Leicester',
          'R20' => 'Peterborough',
          'R24' => 'Norwich',
          'R26' => 'Great Yarmouth',
          'S13' => 'Birmingham',
          'S15' => 'Northampton',
          'T16' => 'Wolverton',
          'T20' => 'Cambridge',
          'T24' => 'Ipswich',
          'U11' => 'Gloucester',
          'U23' => 'Colchester',
          'U25' => 'Harwich',
          'V8' => 'Cardiff & Newport',
          'V10' => 'Bristol',
          'V14' => 'Swindon',
          'V16' => 'Reading',
          'V20' => 'London',
          'V22' => 'Southend',
          'W11' => 'Bath & Trowbridge',
          'W19' => 'Kingston & Reigate',
          'W23' => 'Ashford',
          'W25' => 'Dover',
          'X14' => 'Southampton',
          'X16' => 'Gosport & Portsmouth',
          'X20' => 'Brighton',
          'X22' => 'Hastings',
          'Y11' => 'Weymouth',
          'Y13' => 'Bournemouth',
        }.freeze

        UNIT1_TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 1,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 8,
          '9' => 7,
          '55' => 1,
          '56' => 1,
          '12' => 2,
          '13' => 1,
          '14' => 3,
          '15' => 2,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '52' => 2,
          '87' => 1,
          '88' => 1,
          '32' => 1,
          '34' => 1,
          '38' => 2,
          '41' => 1,
          '42' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
        }.freeze

        UNIT2_TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 1,
          '4' => 1,
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 4,
          '9' => 4,
          '55' => 1,
          '56' => 1,
          '69' => 1,
          '114' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_1',
          },
          '12' => 3,
          '14' => 2,
          '15' => 2,
          '16' => 1,
          '18' => 1,
          '19' => 2,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '52' => 2,
          '33' => 1,
          '34' => 1,
          '38' => 3,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '47' => 1,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '49' => 1,
          '50' => 1,
          '51' => 1,
        }.freeze

        UNIT3_TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 1,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 3,
          '8' => 6,
          '9' => 5,
          '55' => 1,
          '56' => 1,
          '115' => 1,
          '12' => 2,
          '13' => 1,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '19' => 1,
          '23' => 3,
          '24' => 3,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '52' => 2,
          '81' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:2;path=a:2,b:4;path=a:4,b:0',
          },
          '34' => 1,
          '38' => 2,
          '39' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '63' => 2,
          '66' => 2,
          '67' => 1,
          '118' => 1,
        }.freeze

        def append_game_tiles(gtiles, new_tiles)
          new_tiles.each do |k, v|
            if gtiles[k] && v.is_a?(Hash)
              raise GameError, "conflicting tile definitions for tile #{k}" unless gtiles[k].is_a?(Hash)

              gtiles[k].count += v.count
            elsif gtiles[k]
              raise GameError, "conflicting tile definitions for tile #{k}" if gtiles[k].is_a?(Hash)

              gtiles[k] += v
            else
              gtiles[k] = v
            end
          end
        end

        def game_tiles
          gtiles = {}
          append_game_tiles(gtiles, UNIT1_TILES) if @units[1]
          append_game_tiles(gtiles, UNIT2_TILES) if @units[2]
          append_game_tiles(gtiles, UNIT3_TILES) if @units[3]
          gtiles
        end

        # rubocop:disable Layout/LineLength
        UNIT1_HEXES = {
          white: {
            %w[R8
               R14
               R18
               R22
               S9
               S11
               S17
               S19
               S21
               S23
               S25
               T10
               T12
               T14
               T18
               T22
               U9
               U13
               U15
               U17
               U19
               U21
               V12
               V18
               W13
               W15
               W17
               W21
               X8
               X10
               X12
               X18
               X24
               Y9] => '',
            ['T8'] => 'upgrade=cost:100,terrain:mountain',
            %w[R10
               R20
               R26
               S15
               T20
               T24
               U11
               U23
               V16
               X22
               Y11] => 'town=revenue:0',
            %w[W11
               W19] => 'town=revenue:0;town=revenue:0',
            ['W23'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[R16
               R24
               X14
               X20] => 'city=revenue:0',
          },
          yellow: {
            %w[R12
               V8
               X16] => 'city=revenue:0;city=revenue:0;label=OO',
          },
          green: {
            ['S13'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;label=BGM',
            ['V10'] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0',
            ['V20'] => 'city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=L',
          },
          gray: {
            ['T16'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['V14'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['V22'] => 'city=revenue:20,loc:4;path=a:1,b:_0;path=a:1,b:3;path=a:0,b:5',
            ['W9'] => 'path=a:0,b:3;path=a:0,b:4;path=a:3,b:4',
            ['W25'] => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0',
            ['Y13'] => 'city=revenue:20;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            %w[Y17
               Y19] => 'path=a:2,b:3',
          },
        }.freeze

        UNIT2_HEXES = {
          white: {
            %w[L8
               L10
               L16
               M17
               M19
               N16
               P20
               Q9
               Q19] => '',
            %w[L12
               M11
               M13
               O13
               P12
               P14] => 'upgrade=cost:100,terrain:mountain',
            %w[O17
               O19
               P10] => 'upgrade=cost:40,terrain:water',
            %w[L18
               P18] => 'town=revenue:0',
            %w[M15
               N12
               Q13] => 'town=revenue:0;town=revenue:0',
            ['N18'] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[L14
               N10
               Q15
               Q17] => 'city=revenue:0',
          },
          yellow: {
            %w[N14
               P16] => 'city=revenue:0;city=revenue:0;label=OO',
          },
          green: {
            ['O9'] => 'city=revenue:40;city=revenue:40;path=a:3,b:_0;path=a:5,b:_1;label=L',
            ['O11'] => 'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=BGM',
          },
          gray: {
            ['M9'] => 'city=revenue:10;town=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_1',
            ['O15'] => 'city=revenue:20,loc:0.5;city=revenue:20,loc:3.5;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1',
            ['P8'] => 'path=a:1,b:4;path=a:4,b:5;path=a:1,b:5',
            ['Q11'] => 'city=revenue:10,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
          },
        }.freeze

        UNIT3_HEXES = {
          white: {
            %w[C11
               G11
               H12
               H14
               I5
               J8] => '',
            %w[C9
               D2
               D4
               D6
               D8
               E3
               E5
               H8
               H10
               I3
               I7
               I9
               I11
               J4
               J12
               K9
               K11] => 'upgrade=cost:100,terrain:mountain',
            ['C7'] => 'town=revenue:0;upgrade=cost:100,terrain:mountain',
            ['D10'] => 'town=revenue:0',
            ['E9'] => 'city=revenue:0;upgrade=cost:80,terrain:water',
            ['F4'] => 'town=revenue:0;upgrade=cost:140,terrain:mountain|water',
            ['F6'] => 'town=revenue:0',
            ['F8'] => 'town=revenue:0town=revenue:0;upgrade=cost:120,terrain:water',
            ['G3'] => 'city=revenue:0',
            ['G7'] => 'town=revenue:0;town=revenue:0',
            ['H4'] => 'town=revenue:0;town=revenue:0',
            ['H6'] => 'city=revenue:0',
            ['I13'] => 'town=revenue:0;town=revenue:0',
            ['J2'] => 'city=revenue:0',
            ['J6'] => 'city=revenue:0',
            ['J10'] => 'city=revenue:0',
            ['K13'] => 'town=revenue:0',
            ['K15'] => 'town=revenue:0;town=revenue:0',
          },
          yellow: {
            ['G9'] => 'city=revenue:0,loc:1;city=revenue:0,loc:3',
            ['J14'] => 'city=revenue:0,loc:5;city=revenue:0,loc:2;upgrade=cost:40,terrain:water',
          },
          green: {
            ['G5'] => 'city=revenue:40;path=a:1,b:_0;city=revenue:40;path=a:3,b:_1;city=revenue:40;path=a:5,b:_2',
          },
          gray: {
            ['B8'] => 'city=revenue:20,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['B12'] => 'city=revenue:30,loc:0;path=a:0,b:_0',
            ['E1'] => 'city=revenue:20,loc:2.5;path=a:3,b:_0;path=a:4,b:_0',
            ['E7'] => 'city=revenue:10,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['F2'] => 'town=revenue:10,loc:4;path=a:4,b:_0;town=revenue:10,loc:1;path=a:5,b:_1',
            ['F10'] => 'town=revenue:10,loc:2;path=a:2,b:_0;path=a:5,b:0',
            ['K7'] => 'city=revenue:10,loc:3;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze

        UNIT1_OFFMAP_HEXES = {
          gray: {
            ['Q7'] => 'offboard=revenue:0,visit_cost:99;path=a:5,b:_0',
            %w[Q9
               Q11
               Q13
               Q15
               Q17
               Q19
               Q23
               Q25] => 'offboard=revenue:0,visit_cost:99;path=a:0,b:_0;path=a:5,b:_0',
            %w[R6
               T6
               V6
               X6] => 'offboard=revenue:0,visit_cost:99;path=a:4,b:_0',
            %w[S7
               U7] => 'offboard=revenue:0,visit_cost:99;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['Y7'] => 'offboard=revenue:0,visit_cost:99;path=a:3,b:_0;path=a:4,b:_0',
            ['Z8'] => 'offboard=revenue:0,visit_cost:99;path=a:3,b:_0',
            ['Z10'] => 'offboard=revenue:0,visit_cost:99;path=a:2,b:_0;path=a:3,b:_0',
            ['Z12'] => 'offboard=revenue:0,visit_cost:99;path=a:2,b:_0',
          },
        }.freeze

        UNIT2_OFFMAP_HEXES = {
          gray: {
            %w[K9
               K11
               K13
               K15] => 'offboard=revenue:0,visit_cost:99;path=a:0,b:_0;path=a:5,b:_0',
            ['Q7'] => 'offboard=revenue:0,visit_cost:99;path=a:4,b:_0',
            ['R8'] => 'offboard=revenue:0,visit_cost:99;path=a:3,b:_0',
            %w[R10
               R12
               R14
               R16
               R18] => 'offboard=revenue:0,visit_cost:99;path=a:2,b:_0;path=a:3,b:_0',
            ['R20'] => 'offboard=revenue:0,visit_cost:99;path=a:2,b:_0',
          },
        }.freeze

        UNIT3_OFFMAP_HEXES = {
          gray: {
            %w[B6
               C1] => 'offboard=revenue:0,visit_cost:99;path=a:5,b:_0',
            %w[B10
               C3] => 'offboard=revenue:0,visit_cost:99;path=a:0,b:_0;path=a:5,b:_0',
            ['C5'] => 'offboard=revenue:0,visit_cost:99;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0',
            %w[L8
               L10
               L12
               L14] => 'offboard=revenue:0,visit_cost:99;path=a:2,b:_0;path=a:3,b:_0',
            ['L16'] => 'offboard=revenue:0,visit_cost:99;path=a:2,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        def append_game_hexes(ghexes, new_hexes)
          existing_coords = []
          ghexes.each { |_color, hex_hash| existing_coords.concat(hex_hash.keys) }
          existing_coords.flatten!

          new_hexes.each do |color, hex_hash|
            hex_hash.each do |coords, value|
              # skip over a coordinate that has already been defined, regardless of color
              coords.dup.each do |new_coord|
                coords.delete(new_coord) if existing_coords.include?(new_coord)
              end
              next if coords.empty?

              if ghexes[color]
                hexes_coords, = ghexes[color].find { |_, v| v == value }
                if hexes_coords
                  # this defintion is already used for this color => add the new coordinates to it
                  ghexes[color].delete(hexes_coords)
                  hexes_coords.concat(coords)
                  ghexes[color][hexes_coords] = value
                else
                  # new definition for this color
                  ghexes[color][coords] = value
                end
              else
                # new color
                ghexes[color] = {}
                ghexes[color][coords] = value
              end
            end
          end
        end

        def game_hexes
          ghexes = {}
          append_game_hexes(ghexes, UNIT1_HEXES) if @units[1]
          append_game_hexes(ghexes, UNIT2_HEXES) if @units[2]
          append_game_hexes(ghexes, UNIT3_HEXES) if @units[3]

          # append_game_hexes will ignore "spike" hexes if they are already defined
          append_game_hexes(ghexes, UNIT1_OFFMAP_HEXES) if @units[1]
          append_game_hexes(ghexes, UNIT2_OFFMAP_HEXES) if @units[2]
          append_game_hexes(ghexes, UNIT3_OFFMAP_HEXES) if @units[3]
          ghexes
        end
      end
    end
  end
end
