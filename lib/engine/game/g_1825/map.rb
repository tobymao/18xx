# frozen_string_literal: true

module Engine
  module Game
    module G1825
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
          # unit 4
          # Inverness is moved to A5 in location_name in game.rb
          'c8' => 'Wick',
          'a2' => 'Ullapool',
          'a4' => 'Dingwall',
          'a6' => 'Invergordon',
          'a8' => 'Elgin',
          'a12' => 'Fraserburgh',
          'B0' => 'Malaig',
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
          # G7 now handled in game.rb for variant DB3
          'G9' => 'Edinburgh & Leith',
          'G13' => 'Berwick',
          'H4' => 'Kilmarnock & Ayr',
          'H6' => 'Motherwell',
          'H10' => 'Galashiels',
          'I13' => 'Morpeth & Blythe',
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
          # R1
          'P4' => 'Holyhead',
          'Q5' => 'Portmodoc',
          'S5' => 'Aberystwyth',
          'T2' => 'Fishguard',
          'U1' => 'MilfordHaven',
          'V6' => 'Swansea',
          # R2
          'X4' => 'Barnstaple',
          'Y7' => 'Exeter',
          'Z2' => 'Fowey',
          'Z4' => 'Devonport & Plymouth',
          'Z6' => 'Torquay',
          'AA-1' => 'Penzance',
          'AA1' => 'Falmouth',
          # R3
          'Q23' => 'Melton Constable',
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
        }.freeze
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
          '118' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
        }.freeze

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
        }.freeze

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
        }.freeze

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
        }.freeze

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
        }.freeze
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
        }.freeze

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
        }.freeze

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
          '3' => %w[12 14 15 119 206],
          '4' => %w[14 15 119 206],
          '58' => %w[12 13 14 15 119 206],
          # not a dit at all but a yellow city, how exciting
          '115' => '206',
          # HACK: for 119 (green/brown tile that upgrades to gray)
          '119' => %w[51],
        }.freeze

        ILLEGAL_UPGRADES = {
          '81' => %w[40],
          '82' => %w[41],
          '83' => %w[42],
        }.freeze

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
          append_game_tiles(gtiles, UNIT1_TILES) if @units[1]
          append_game_tiles(gtiles, UNIT2_TILES) if @units[2]
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
            ['V20'] => 'city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:4,b:_4;path=a:5,b:_5;label=LD',
          },
          sepia: {
            ['T16'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['U25'] => 'city=revenue:20;path=a:1,b:_0',
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
          sepia: {
            ['M9'] => 'city=revenue:10;town=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_1;path=a:5,b:_1',
            ['O15'] => 'city=revenue:20,loc:0.5;city=revenue:20,loc:3.5;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1',
            ['P8'] => 'path=a:1,b:4;path=a:4,b:5;path=a:1,b:5',
            ['Q11'] => 'city=revenue:10;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
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
            ['F8'] => 'town=revenue:0;town=revenue:0;upgrade=cost:120,terrain:water',
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
            ['G9'] => 'city=revenue:0,loc:1;city=revenue:0,loc:3;label=OO',
            ['J14'] => 'city=revenue:0,loc:5;city=revenue:0,loc:2;upgrade=cost:40,terrain:water;label=OO',
          },
          green: {
            ['G5'] => 'city=revenue:40;path=a:1,b:_0;city=revenue:40;path=a:3,b:_1;city=revenue:40;path=a:5,b:_2;label=BGM',
          },
          sepia: {
            ['B8'] => 'city=revenue:20,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['B12'] => 'city=revenue:30;path=a:0,b:_0',
            ['E1'] => 'city=revenue:20,loc:2.5;path=a:3,b:_0;path=a:4,b:_0',
            ['E7'] => 'city=revenue:10,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['F2'] => 'town=revenue:10,loc:4;path=a:4,b:_0;town=revenue:10,loc:1;path=a:5,b:_1',
            ['F10'] => 'town=revenue:10,loc:2;path=a:2,b:_0;path=a:5,b:0',
            ['K7'] => 'city=revenue:10,loc:3;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze

        UNIT4_HEXES = {
          white: {
            %w[b7
               A7
               A9
               A11
               A13
               B4
               B10
               C1] => '',
            %w[c6
               b3
               b5
               A3
               B2
               B6
               B8
               C5] => 'upgrade=cost:100,terrain:mountain',
            %w[c8
               A5
               B12] => 'city=revenue:0',
            %w[a2
               a4
               a6
               C3] => 'town=revenue:0',
          },
          sepia: {
            %w[a8
               a12] => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0',
            ['B0'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze

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
        }.freeze

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
        }.freeze

        R3_HEXES = {
          white: {
            ['Q25'] => '',
          },
          sepia: {
            ['Q23'] => 'city=revenue:10;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze

        DB2_HEXES = {
          white: {
            ['W23'] => 'city=revenue:0',
          },
        }.freeze

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
        }.freeze

        UNIT1_OFFMAP_HEXES = {
          gray: {
            %w[Q7
               Q9
               Q11
               Q13
               Q15
               Q17
               Q19
               Q23
               Q25
               R6
               T6
               V6
               X6
               S7
               U7
               Y7] => '',
          },
        }.freeze

        UNIT2_OFFMAP_HEXES = {
          gray: {
            %w[K9
               K11
               K13
               K15
               Q7
               R8
               R10
               R12
               R14
               R16
               R18
               R20] => '',
          },
        }.freeze

        UNIT3_OFFMAP_HEXES = {
          gray: {
            %w[B6
               C1
               B10
               C3
               C5
               L8
               L10
               L12
               L14
               L16] => '',
          },
        }.freeze

        R1_OFFMAP_HEXES = {
          gray: {
            %w[P8
               Q9] => '',
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
