# frozen_string_literal: true

module Engine
  module Game
    module G18TS
      module Map
        LAYOUT = :flat
        AXES = { x: :letter, y: :number }.freeze
        LOCATION_NAMES = {
          'D16' => 'Meadville',
          'F22' => 'Washington',
          'H16' => 'Brookville',
          'F20' => 'Beaver',
          'F18' => 'Allegheny Mines & Coaltown',
          'G19' => 'Gibsonia & Butler',
          'H22' => 'Oliphant & Vances Mill',
          'I13' => 'Turtlepoint & Coudersport',
          'K13' => 'Driftwood & Goodyear',
          'L16' => 'Mifflintown & New Bloomfield',
          'N10' => 'Barclay',
          'O15' => 'Coatesville & Downingtown',
          'P8' => 'Easton',
          'P18' => 'Chichester',
          'P2' => 'Branchville',
          'Q13' => 'Churchville',
          'R8' => 'Waterloo',
          'R4' => 'Paterson',
          'V6' => 'Locust Point',
          'R20' => 'Allegheny Mines & Coaltown',
          'S17' => 'Pennsauken',
          'S5' => 'Jersey City',
          'T12' => 'Jamesburg',
          'U17' => 'Burlington & Mount Holly',
          'U9' => 'Long Island City & Williamsburg',
          'W17' => 'Toms River',
          'X22' => 'Sea Isle City',
          'C15' => 'Erie',
          'C19' => 'Hillsville Quarry',
          'E19' => 'New Castle',
          'E17' => 'Mercer',
          'G23' => 'Uniontown',
          'G21' => 'Pittsburgh',
          'G17' => 'Kittanning & Clarion',
          'H20' => 'Greensburg',
          'I21' => 'Somerset',
          'I17' => 'Clearview',
          'H14' => 'Smethport & Ridgeway',
          'J20' => 'Bedford',
          'J14' => 'Emporium',
          'K19' => 'Chambersburg',
          'L18' => 'Carlisle',
          'L14' => 'Lock Haven & Middleburg',
          'M17' => 'Harrisburg',
          'M19' => 'York',
          'M13' => 'Lewisburg & Sunbury',
          'N12' => 'Danville & Bloomsburg',
          'O13' => 'Reading',
          'O11' => 'Pottsville',
          'O17' => 'Rohrerstown',
          'O5' => 'Stroudsburg',
          'P20' => 'Strasburg',
          'P16' => 'Westchester & Media',
          'P12' => 'Allentown',
          'P4' => 'Lake Hopatcong',
          'Q15' => 'Philadelphia',
          'R12' => 'Trenton',
          'S3' => 'Rockland',
          'S21' => 'Pittsgrove',
          'S19' => 'Gloucester & Woodbury',
          'T18' => 'Camden',
          'T14' => 'Bordentown',
          'T6' => 'Harlem',
          'U19' => 'Hammonton',
          'U5' => 'New Rochelle',
          'U3' => 'Port Chester',
          'V14' => 'Freehold',
          'V12' => 'Arthur Kill & Verrazano Tunnel',
          'V8' => 'Jamaica',
          'W21' => 'Atlantic City',
          'W15' => 'Farmingdale',
        }.freeze

        # rubocop:disable Layout/LineLength
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
          '14' => 2,
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
          '32' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=LD',
          },
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
        }.deep_freeze
        # rubocop:enable Layout/LineLength

        UNIT2_TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 1,
          '4' => 1,
          '5' => 2,
          '6' => 2,
          '7' => 3,
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
          '51' => 2,
        }.deep_freeze

        UNIT3_TILES = {
          '1' => 3,
          '2' => 3,
          '3' => 5,
          '4' => 8,
          '5' => 6,
          '6' => 8,
          '7' => 12,
          '8' => 21,
          '9' => 18,
          '55' => 3,
          '56' => 3,
          '58' => 5,
          '69' => 3,
          '114' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_1',
          },
          '12' => 7,
          '13' => 3,
          '14' => 9,
          '15' => 8,
          '16' => 3,
          '17' => 1,
          '18' => 2,
          '19' => 4,
          '20' => 3,
          '21' => 1,
          '22' => 1,
          '23' => 9,
          '24' => 9,
          '25' => 2,
          '26' => 3,
          '27' => 3,
          '28' => 3,
          '29' => 3,
          '30' => 1,
          '31' => 1,
          '32' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;city=revenue:70;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=NY',
          },
          '33' => 1,
          '34' => 3,
          '35' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          '36' => 1,
          '38' => 11,
          '39' => 3,
          '40' => 3,
          '41' => 4,
          '42' => 4,
          '43' => 3,
          '44' => 3,
          '45' => 2,
          '46' => 2,
          '47' => 4,
          '48' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=NY',
          },
          '49' => 2,
          '50' => 3,
          '51' => 5,
          '52' => 7,
          '60' => 2,
          '64' => 2,
          '65' => 2,
          '66' => 4,
          '67' => 3,
          '68' => 2,
          '118' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          '119' => 3,
          '166' => 4,
          '167' => 4,
          '168' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=OO',
          },
          '174' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,loc:0.5;city=revenue:50,loc:4.5;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_1;path=a:5,b:_1;path=a:1,b:4;label=OO',
          },
          '200' => 2,
          '205' => 3,
          '206' => 3,
          '887' => 5,
          '888' => 5,
        }.deep_freeze

        R1_TILES = {
          '2' => 1,
          '3' => 1,
          '4' => 1,
          '6' => 2,
          '7' => 2,
          '8' => 2,
          '69' => 1,
          '10' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,loc:0;city=revenue:30,loc:3;path=a:5,b:_0;path=a:2,b:_1;label=OO',
          },
          '11' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10,visit_cost:0;path=a:0,b:2;path=a:2,b:_0;path=a:_0,b:4;path=a:0,b:4;label=HALT',
          },
          '13' => 1,
          '14' => 1,
          '23' => 1,
          '24' => 1,
          '35' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          '37' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,loc:0;city=revenue:40,loc:3;path=a:2,b:_0;path=a:5,b:_1;path=a:2,b:5;label=OO',
          },
          '38' => 1,
          '66' => 1,
        }.deep_freeze

        R2_TILES = {
          '3' => 1,
          '58' => 1,
          '115' => 1,
          '10' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,loc:0;city=revenue:30,loc:3;path=a:5,b:_0;path=a:2,b:_1;label=OO',
          },
          '35' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          '37' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,loc:0;city=revenue:40,loc:3;path=a:2,b:_0;path=a:5,b:_1;path=a:2,b:5;label=OO',
          },
        }.deep_freeze

        R3_TILES = {
          '8' => 1,
          '9' => 2,
          '11' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10,visit_cost:0;path=a:0,b:2;path=a:2,b:_0;path=a:_0,b:4;path=a:0,b:4;label=HALT',
          },
          '14' => 1,
        }.deep_freeze

        K1_TILES = {
          '17' => 1,
          '18' => 1,
          '21' => 1,
          '22' => 1,
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
          '47' => 1,
        }.freeze

        # rubocop:disable Layout/LineLength
        K3_TILES = {
          '48' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;city=revenue:100;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=LD',
          },
          '49' => 1,
          '50' => 2,
          '51' => 3,
          '60' => 2,
          '166' => 4,
          '167' => 4,
          '168' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=OO',
          },
        }.deep_freeze
        # rubocop:enable Layout/LineLength

        K5_TILES = {
          '15' => 1,
          '69' => 1,
          '119' => 1,
        }.freeze

        K6_TILES = {
          '58' => 2,
          '198' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=OO',
          },
          '199' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=OO',
          },
          '11' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10,visit_cost:0;path=a:0,b:2;path=a:2,b:_0;path=a:_0,b:4;path=a:0,b:4;label=HALT',
          },
          '82' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:1;path=a:1,b:3;path=a:0,b:3',
          },
          '83' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:5;path=a:5,b:3;path=a:0,b:3',
          },
          '119' => 2,
          '200' => 2,
        }.deep_freeze

        # rubocop:disable Layout/LineLength
        D1_TILES = {
          '7' => 2,
          '58' => 2,
          '115' => 2,
          '10' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:30,loc:0;city=revenue:30,loc:3;path=a:5,b:_0;path=a:2,b:_1;label=OO',
          },
          '11' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'town=revenue:10,visit_cost:0;path=a:0,b:2;path=a:2,b:_0;path=a:_0,b:4;path=a:0,b:4;label=HALT',
          },
          '17' => 1,
          '18' => 1,
          '20' => 1,
          '21' => 1,
          '22' => 1,
          '30' => 1,
          '31' => 1,
          '82' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:1;path=a:1,b:3;path=a:0,b:3',
          },
          '83' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:5;path=a:5,b:3;path=a:0,b:3',
          },
          '35' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          '36' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:4;label=OO',
          },
          '37' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,loc:0;city=revenue:40,loc:3;path=a:2,b:_0;path=a:5,b:_1;path=a:2,b:5;label=OO',
          },
          '38' => 1,
          '39' => 1,
          '40' => 1,
          '43' => 1,
          '44' => 1,
          '47' => 1,
          '119' => 2,
          '174' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:50,loc:0.5;city=revenue:50,loc:4.5;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_1;path=a:5,b:_1;path=a:1,b:4;label=OO',
          },
          '200' => 2,
        }.deep_freeze

        DB1_UNIT3_ANTITILES = {
          '14' => -1,
          '15' => -1,
        }.freeze

        DB3_TILES = {
          '58' => 1,
          '206' => 1,
        }.freeze

        # rubocop:enable Layout/LineLength

        # This includes upgrades for the DB1 kit tiles 887/888 and DB3 #206.
        # Games without DB kits lack those tiles so are unaffected.
        EXTRA_UPGRADES = {
          # gentle curve to three curves with a halt
          '8' => %w[11],
          # yellow double-dit to green K or X city
          '1' => %w[14 888],
          '2' => %w[15 887],
          '55' => %w[14 888],
          '56' => %w[15 887],
          '69' => %w[119],
          '114' => %w[15 887],
          '198' => %w[119],
          '199' => %w[119],
          '887' => %w[63 166],
          '888' => %w[63 166],
          # yellow single-dit to green city (also brown/green city)
          '3' => %w[12 14 15 119 205 206],
          '4' => %w[14 15 119 205 206],
          '58' => %w[12 13 14 15 119 205 206],
          '119' => %w[166],
        }.deep_freeze

        ILLEGAL_UPGRADES = {
          '81' => %w[40],
          '82' => %w[41],
          '83' => %w[42],
          '12' => %w[166],
          '13' => %w[166],
          '205' => %w[166],
          '206' => %w[166],
        }.deep_freeze

        def append_game_tiles(gtiles, new_tiles)
          new_tiles.each do |k, v|
            if gtiles[k] && v.is_a?(Hash)
              raise GameError, "conflicting tile definitions for tile #{k}" unless gtiles[k].is_a?(Hash)

              gtiles[k]['count'] += v['count']
            elsif gtiles[k]
              raise GameError, "conflicting tile definitions for tile #{k}" if gtiles[k].is_a?(Hash)

              gtiles[k] += v
            else
              gtiles[k] = v.dup
            end
            number = gtiles[k].is_a?(Hash) ? gtiles[k]['count'] : gtiles[k]
            # this was if number<=0 raise GameError ... end but rubocop gives
            # a complaint that seems frankly barking to me
            next if number.positive?
            raise GameError, "negative number of tile #{k}" if number.negative?

            gtiles.delete(k)
          end
        end

        def game_tiles
          gtiles = {}
          append_game_tiles(gtiles, UNIT3_TILES) if @units[1]
          append_game_tiles(gtiles, UNIT3_TILES) if @units[2]
          append_game_tiles(gtiles, UNIT3_TILES) if @units[3]
          append_game_tiles(gtiles, R1_TILES) if @regionals[1]
          append_game_tiles(gtiles, R2_TILES) if @regionals[2]
          append_game_tiles(gtiles, R3_TILES) if @regionals[3]
          append_game_tiles(gtiles, K1_TILES) if @kits[1]
          append_game_tiles(gtiles, K3_TILES) if @kits[3]
          append_game_tiles(gtiles, K5_TILES) if @kits[5]
          append_game_tiles(gtiles, K6_TILES) if @kits[6]
          append_game_tiles(gtiles, D1_TILES) if @optional_rules.include?(:d1)
          db1_tiles(gtiles) if @optional_rules.include?(:db1)
          append_game_tiles(gtiles, DB3_TILES) if @optional_rules.include?(:db3)
          gtiles
        end

        def db1_tiles(gtiles)
          gtiles.delete('87')
          gtiles.delete('88')
          eightysevens = ((@units[1] ? 2 : 0) + (@units[3] ? 1 : 0))
          gtiles['887'] = eightysevens
          gtiles['888'] = eightysevens
          append_game_tiles(gtiles, DB1_UNIT3_ANTITILES) if @units[3]
          gtiles
        end

        # rubocop:disable Layout/LineLength

        FULL_GAME_HEXES = {
          white: {
            %w[D18 G15 I19 J12 K11 L12 L10 N8 O9 O19 P6 P10 P14 Q3 Q5 Q7 Q9 Q11 Q17 Q19 R6 R10 R14 R16 R18 S7 S9 S11 S13 S15 T10 T16 U11 U13 U15 V4 V10 V16 V18 V20 W19 S11 U7] =>'',
            %w[H18 I15 I23 J16 J18 K15 K17] =>'upgrade=cost:100,terrain:mountain',
            %w[C17 D20 E21 N14 V22 W23 O21 Q21 R20] =>'upgrade=cost:100,terrain:water',
            %w[N18 M9 M11 M15] =>'upgrade=cost:40,terrain:water',
            ['N14'] =>'upgrade=cost:60,terrain:water',
            ['N16'] =>'upgrade=cost:120,terrain:water',
            %w[D16 F20 N10 P8 P18 P2 Q13 R8 R4 V6 S17 S5 T12 W17 X22 I21] =>'town=revenue:0',           
            ['F22'] =>'town=revenue:0;upgrade=cost:100,terrain:water',
            ['H16'] =>'town=revenue:0;upgrade=cost:100,terrain:mountain',
            %w[G19 H22 I13 K13 L16 O15 U17 U9] =>'town=revenue:0;town=revenue:0',
            ['F18'] =>'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water',
            ['R20'] =>'town=revenue:0;town=revenue:0;upgrade=cost:100,terrain:water',
            %w[E17 G23 H20 J14 L18 O13 O11 P12 P4 V14 V8 W21] =>'city=revenue:0',
            ['P20'] =>'city=revenue:20;path=a:3,b:_0',
            ['I17'] =>'city=revenue:0;upgrade=cost:100,terrain:mountain',
            ['U5'] =>'city=revenue:0;upgrade=cost:40,terrain:water',
            },
            gray: {
            ['C15'] =>'city=revenue:30,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['C19'] =>'city=revenue:20,loc:4.5;path=a:5,b:_0;path=a:4,b:_0',
            ['E19'] =>'city=revenue:10,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['F24'] =>'town=revenue:10,loc:3;town=revenue:10,loc:4;path=a:3,b:_0;path=a:4,b:_1',
            ['F16'] =>'town=revenue:10,loc:1;path=a:1,b:_0;path=a:4,b:5',
            ['J20'] =>'city=revenue:10,loc:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['K19'] =>'city=revenue:10,loc:center;town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:3,b:_1;path=a:4,b:_1',
            ['M13'] =>'city=revenue:20,loc:0;city=revenue:20,loc:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1',
            ['N20'] =>'path=a:3,b:4;path=a:3,b:5',
            ['O5'] =>'city=revenue:10,loc:4.5;path=a:5,b:_0;path=a:4,b:_0',
            ['S3'] =>'city=revenue:20;path=a:0,b:_0',
            ['S21'] =>'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
            ['T6'] =>'city=revenue:20,loc:3;path=a:0,b:_0;path=a:0,b:2;path=a:5,b:4;path=a:0,b:1',
            ['U19'] =>'city=revenue:10,loc:3.5;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:2,b:5',
            ['U3'] =>'city=revenue:20,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['W15'] =>'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            },
            green: {
            ['G21'] =>'city=revenue:40,loc:0;city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=BGM',
            ['M17'] =>'city=revenue:40,loc:1;city=revenue:40,loc:3;city=revenue:40,loc:5;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;label=BGM',
            ['M19'] =>'city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:2,b:_0;path=a:4,b:_1;label=L',
            ['Q15'] =>'city=revenue:40,loc:0;city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=BGM',
            ['T18'] =>'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0',
            ['T8'] =>'city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=NY',
            },
            yellow: {
            ['G17'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['H14'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['L14'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['N12'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['P16'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['S19'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['V12'] =>'city=revenue:0;city=revenue:0;label=OO',
            },
            sepia: {
            ['O17'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['R12'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['T14'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
            blue: {
            ['W9'] =>'path=a:1,b:2;',
            },
        }.deep_freeze

        UNIT1_HEXES = {
          white: {
            %w[J12 K11 L12 L10 N8 O9 O19 P6 P10 P14 Q3 Q5 Q7 Q9 Q11 Q17 Q19 R6 R10 R14 R16 R18 S7 S9 S11 S13 S15 T10 T16 U11 U13 U15 V4 V10 V16 V18 V20 W19 S11 U7] =>'',
            %w[I15 J16 K15 K17] =>'upgrade=cost:100,terrain:mountain',
            %w[N14 V22 W23 O21 Q21 R20] =>'upgrade=cost:100,terrain:water',
            %w[N18 M9 M11 M15] =>'upgrade=cost:40,terrain:water',
            ['N14'] =>'upgrade=cost:60,terrain:water',
            ['N16'] =>'upgrade=cost:120,terrain:water',
            %w[N10 P8 P18 P2 Q13 R8 R4 V6 S17 S5 T12 W17 X22] =>'town=revenue:0',                    
            %w[I13 K13 L16 O15 U17 U9] =>'town=revenue:0;town=revenue:0',
            ['R20'] =>'town=revenue:0;town=revenue:0;upgrade=cost:100,terrain:water',
            %w[J14 L18 O13 O11 P12 P4 V14 V8 W21] =>'city=revenue:0',
            ['P20'] =>'city=revenue:20;path=a:3,b:_0',
            ['U5'] =>'city=revenue:0;upgrade=cost:40,terrain:water',
            },
            gray: {
            ['K19'] =>'city=revenue:10,loc:0;town=revenue:10;path=a:3,b:_0;path=a:3,b:_1;path=a:4,b:_1',
            ['M13'] =>'city=revenue:20,loc:0;city=revenue:20,loc:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1',
            ['N20'] =>'path=a:3,b:4;path=a:3,b:5',
            ['O5'] =>'city=revenue:10,loc:4.5;path=a:5,b:_0;path=a:4,b:_0',
            ['S3'] =>'city=revenue:20;path=a:0,b:_0',
            ['S21'] =>'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
            ['T6'] =>'city=revenue:20,loc:3;path=a:0,b:_0;path=a:0,b:2;path=a:5,b:4;path=a:0,b:1',
            ['U19'] =>'city=revenue:10,loc:3.5;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:2,b:5',
            ['U3'] =>'city=revenue:20,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['W15'] =>'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            },
            green: {
            ['M17'] =>'city=revenue:40,loc:1;city=revenue:40,loc:3;city=revenue:40,loc:5;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;label=BGM',
            ['M19'] =>'city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:2,b:_0;path=a:4,b:_1;label=L',
            ['Q15'] =>'city=revenue:40,loc:0;city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=BGM',
            ['T18'] =>'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0',
            ['T8'] =>'city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=NY',
            },
            yellow: {
            ['H14'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['L14'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['N12'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['P16'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['S19'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['V12'] =>'city=revenue:0;city=revenue:0;label=OO',
            },
            sepia: {
            ['O17'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['R12'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['T14'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
            blue: {
            ['W9'] =>'path=a:1,b:2;',
            },
        }.deep_freeze

        UNIT2_HEXES = {
          white: {
            %w[D18 G15 I19 J12 K11 L12 L10 N8 O9 O19] =>'',
            %w[H18 I15 I23 J16 J18 K15 K17] =>'upgrade=cost:100,terrain:mountain',
            %w[C17 D20 E21 N14] =>'upgrade=cost:100,terrain:water',
            %w[N18 M9 M11 M15] =>'upgrade=cost:40,terrain:water',
            ['N14'] =>'upgrade=cost:60,terrain:water',
            ['N16'] =>'upgrade=cost:120,terrain:water',
            %w[D16 F20 I21 N10] =>'town=revenue:0',           
            ['F22'] =>'town=revenue:0;upgrade=cost:100,terrain:water',
            ['H16'] =>'town=revenue:0;upgrade=cost:100,terrain:mountain',
            %w[G19 H22 I13 K13 L16 O15] =>'town=revenue:0;town=revenue:0',
            ['F18'] =>'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water',
            %w[E17 G23 H20 J14 L18 O13 O11] =>'city=revenue:0',
            ['I17'] =>'city=revenue:0;upgrade=cost:100,terrain:mountain',
            },
            gray: {
            ['C15'] =>'city=revenue:30,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['C19'] =>'city=revenue:20,loc:4.5;path=a:5,b:_0;path=a:4,b:_0',
            ['E19'] =>'city=revenue:10,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['F24'] =>'town=revenue:10,loc:3;town=revenue:10,loc:4;path=a:3,b:_0;path=a:4,b:_1',
            ['F16'] =>'town=revenue:10,loc:1;path=a:1,b:_0;path=a:4,b:5',
            ['J20'] =>'city=revenue:10,loc:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['K19'] =>'city=revenue:10,loc:center;town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:3,b:_1;path=a:4,b:_1',
            ['M13'] =>'city=revenue:20,loc:0;city=revenue:20,loc:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1',
            ['N20'] =>'path=a:3,b:4;'
            },
            green: {
            ['G21'] =>'city=revenue:40,loc:0;city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=BGM',
            ['M17'] =>'city=revenue:40,loc:1;city=revenue:40,loc:3;city=revenue:40,loc:5;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;label=BGM',
            ['M19'] =>'city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:2,b:_0;path=a:4,b:_1;label=L',
            },
            yellow: {
            ['G17'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['H14'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['L14'] =>'city=revenue:0;city=revenue:0;label=OO',
            ['N12'] =>'city=revenue:0;city=revenue:0;label=OO',
            },
            sepia: {
            ['O17'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            },
        }.deep_freeze

        UNIT3_HEXES = {
          white: {
            %w[D18 G15 I19 J12 K11 L12 L10 N8 O9 O19 P6 P10 P14 Q3 Q5 Q7 Q9 Q11 Q17 Q19 R6 R10 R14 R16 R18 S7 S9 S11 S13 S15 T10 T16 U11 U13 U15 V4 V10 V16 V18 V20 W19 S11 U7] =>'',
            %w[H18 I15 I23 J16 J18 K15 K17] =>'upgrade=cost:100,terrain:mountain',
            %w[C17 D20 E21 N14 V22 W23 O21 Q21 R20] =>'upgrade=cost:100,terrain:water',
            %w[N18 M9 M11 M15] =>'upgrade=cost:40,terrain:water',
            ['N14'] =>'upgrade=cost:60,terrain:water',
            ['N16'] =>'upgrade=cost:120,terrain:water',
            %w[D16 F20 I21 N10 P8 P18 P2 Q13 R8 R4 V6 S17 S5 T12 W17 X22] =>'town=revenue:0',                    
            %w[G19 H22 I13 K13 L16 O15 U17 U9] =>'town=revenue:0;town=revenue:0',
            ['R20'] =>'town=revenue:0;town=revenue:0;upgrade=cost:100,terrain:water',
            ['F18'] =>'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water',
            ['F22'] =>'town=revenue:0;upgrade=cost:100,terrain:water',
            ['H16'] =>'town=revenue:0;upgrade=cost:100,terrain:mountain',
            %w[E17 G23 H20 J14 L18 O13 O11 P12 P4 V14 V8 W21] =>'city=revenue:0',
            ['P20'] =>'city=revenue:20;path=a:3,b:_0',
            ['U5'] =>'city=revenue:0;upgrade=cost:40,terrain:water',
            ['I17'] =>'city=revenue:0;upgrade=cost:100,terrain:mountain',
            },
            gray: {
            ['C15'] =>'city=revenue:30,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['C19'] =>'city=revenue:20,loc:4.5;path=a:5,b:_0;path=a:4,b:_0',
            ['E19'] =>'city=revenue:10,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['F24'] =>'town=revenue:10,loc:3;town=revenue:10,loc:4;path=a:3,b:_0;path=a:4,b:_1',
            ['F16'] =>'town=revenue:10,loc:1;path=a:1,b:_0;path=a:4,b:5',
            ['J20'] =>'city=revenue:10,loc:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['K19'] =>'city=revenue:10,loc:center;town=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:3,b:_1;path=a:4,b:_1',
            ['M13'] =>'city=revenue:20,loc:0;city=revenue:20,loc:3;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1',
            ['N20'] =>'path=a:3,b:4;path=a:3,b:5',
            ['O5'] =>'city=revenue:10,loc:4.5;path=a:5,b:_0;path=a:4,b:_0',
            ['S3'] =>'city=revenue:20;path=a:0,b:_0',
            ['S21'] =>'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
            ['T6'] =>'city=revenue:20,loc:3;path=a:0,b:_0;path=a:0,b:2;path=a:5,b:4;path=a:0,b:1',
            ['U19'] =>'city=revenue:10,loc:3.5;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:2,b:5',
            ['U3'] =>'city=revenue:20,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['W15'] =>'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            },
            green: {
            ['G21'] =>'city=revenue:40,loc:0;city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=BGM',
            ['M17'] =>'city=revenue:40,loc:1;city=revenue:40,loc:3;city=revenue:40,loc:5;path=a:1,b:_0;path=a:3,b:_1;path=a:5,b:_2;label=BGM',
            ['M19'] =>'city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:2,b:_0;path=a:4,b:_1;label=L',
            ['Q15'] =>'city=revenue:40,loc:0;city=revenue:40,loc:2;city=revenue:40,loc:4;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=BGM',
            ['T18'] =>'city=revenue:30;path=a:3,b:_0;path=a:5,b:_0',
            ['T8'] =>'city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=NY',
            },
            yellow: {
            %w[G17 H14 L14 N12 P16 S19 V12] =>'city=revenue:0;city=revenue:0;label=OO',
            },
            sepia: {
            ['O17'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['R12'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            ['T14'] =>'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
            blue: {
            ['W9'] =>'path=a:1,b:2;',
            }, 
        }.deep_freeze
     
        R1_HEXES = {
          white: {
            %w[R6
               T4
               U3
               U5] => '',
            %w[Q7
               S7
               T6] => 'upgrade=cost:100,terrain:mountain',
            ['P6'] => 'upgrade=cost:40,terrain:water',
            %w[Q5
               S5] => 'town=revenue:0',
            ['U7'] => 'town=revenue:0;town=revenue:0',
            %w[R8
               T2] => 'city=revenue:0',
          },
          sepia: {
            ['P4'] => 'city=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
            ['U1'] => 'city=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            ['V6'] => 'city=revenue:20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.deep_freeze

        R2_HEXES = {
          white: {
            %w[Y1
               Y3
               Z0] => '',
            %w[X6
               Y5] => 'upgrade=cost:100,terrain:mountain',
            %w[X4
               Z2
               Z6
               AA-1] => 'town=revenue:0',
            %w[Y7
               AA1] => 'city=revenue:0',
          },
          yellow: {
            ['Z4'] => 'city=revenue:0;city=revenue:0;label=OO',
          },
          sepia: {
            ['W9'] => 'city=revenue:10,loc:4.5;path=a:0,b:3;path=a:_0,b:3;path=a:_0,b:4;path=a:_0,b:5',
          },
        }.deep_freeze

        R3_HEXES = {
          white: {
            ['Q25'] => '',
          },
          sepia: {
            ['Q23'] => 'city=revenue:10;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.deep_freeze

        DB2_HEXES = {
          white: {
            ['W23'] => 'city=revenue:0',
          },
        }.deep_freeze

        DB3_HEXES = {
          white: {
            ['I9'] => '',
            ['J6'] => 'town=revenue:0',
            ['G13'] => 'city=revenue:0',
            ['H10'] => 'town=revenue:0;upgrade=cost:100,terrain:mountain',
            ['F4'] => 'town=revenue:0;border=edge:0,type:impassable;upgrade=cost:100,terrain:mountain',
          },
          sepia: {
            ['F2'] => 'town=revenue:10,loc:4;path=a:4,b:_0;path=a:3,b:_0;town=revenue:10,loc:5;path=a:5,b:_1',
          },
        }.deep_freeze

        UNIT1_OFFMAP_HEXES = {
          gray: {
            %w[G15 H16 I17 J18 J20] => '',
          },
        }.deep_freeze

        UNIT2_OFFMAP_HEXES = {
          gray: {
            %w[P8 P10 P12 P14 P16 P18] => '',
          },
        }.deep_freeze

        UNIT3_OFFMAP_HEXES = {
        }.deep_freeze

        R1_OFFMAP_HEXES = {
          gray: {
            %w[P8
               Q9] => '',
          },
        }.deep_freeze
        # rubocop:enable Layout/LineLength

        def append_game_hexes(ghexes, new_hexes)
          existing_coords = []
          ghexes.each { |_color, hex_hash| existing_coords.concat(hex_hash.keys) }
          existing_coords.flatten!

          new_hexes.each do |color, hex_hash|
            hex_hash.each do |raw_coords, value|
              # copy to avoid mutating `new_hexes`
              coords = raw_coords.dup

              # skip over a coordinate that has already been defined, regardless of color
              raw_coords.each do |new_coord|
                coords.delete(new_coord) if existing_coords.include?(new_coord)
              end
              next if coords.empty?

              if ghexes[color]
                hexes_coords, = ghexes[color].find { |_, v| v == value }

                if hexes_coords
                  next unless (hexes_coords & coords).empty?

                  # this defintion is already used for this color => add the new coordinates to it
                  ghexes[color].delete(hexes_coords)
                  new_coords = hexes_coords + coords
                  ghexes[color][new_coords] = value
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
          append_game_hexes(ghexes, DB2_HEXES) if @optional_rules.include?(:db2)
          append_game_hexes(ghexes, DB3_HEXES) if @optional_rules.include?(:db3)
          append_game_hexes(ghexes, UNIT4_HEXES) if @optional_rules.include?(:unit_4)
          append_game_hexes(ghexes, R1_HEXES) if @regionals[1]
          append_game_hexes(ghexes, R2_HEXES) if @regionals[2]
          append_game_hexes(ghexes, R3_HEXES) if @regionals[3]
          append_game_hexes(ghexes, UNIT1_HEXES) if @units[1]
          append_game_hexes(ghexes, UNIT2_HEXES) if @units[2]
          append_game_hexes(ghexes, UNIT3_HEXES) if @units[3]

          # append_game_hexes will ignore offboard hexes if they are already defined
          append_game_hexes(ghexes, R1_OFFMAP_HEXES) if @regionals[1]
          append_game_hexes(ghexes, UNIT1_OFFMAP_HEXES) if @units[1]
          append_game_hexes(ghexes, UNIT2_OFFMAP_HEXES) if @units[2]
          append_game_hexes(ghexes, UNIT3_OFFMAP_HEXES) if @units[3]
          ghexes
        end
      end
    end
  end
end
