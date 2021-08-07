# frozen_string_literal: true

module Engine
  module Game
    module G1825
      module Map
        LAYOUT = :pointy

        LOCATION_NAMES = {
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
        }.freeze

        TILES = {
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
        HEXES = {
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
            ['C7'] => 'town=revenue:0,loc:5.5;upgrade=cost:100,terrain:mountain',
            ['D10'] => 'town=revenue:0,loc:3',
            ['E9'] => 'city=revenue:0,loc:2.5;upgrade=cost:80,terrain:water',
            ['F4'] => 'town=revenue:0,loc:5.5;upgrade=cost:140,terrain:mountain|water',
            ['F6'] => 'town=revenue:0',
            ['F8'] => 'town=revenue:0,loc:1.5;town=revenue:0,loc:3;upgrade=cost:120,terrain:water',
            ['G3'] => 'city=revenue:0,loc:2.5',
            ['G7'] => 'town=revenue:0,loc:1;town=revenue:0,loc:center',
            ['H4'] => 'town=revenue:0,loc:0.5;town=revenue:0,loc:3',
            ['H6'] => 'city=revenue:0,loc:2.5',
            ['I13'] => 'town=revenue:0,loc:center;town=revenue:0,loc:4.5',
            ['J2'] => 'city=revenue:0,loc:1',
            ['J6'] => 'city=revenue:0,loc:3',
            ['J10'] => 'city=revenue:0,loc:1',
            ['K13'] => 'town=revenue:0,loc:3.5',
            ['K15'] => 'town=revenue:0,loc:5;town=revenue:0,loc:0',
          },
          yellow: {
            ['G9'] => 'city=revenue:0,loc:1;city=revenue:0,loc:3',
            ['J14'] => 'city=revenue:0,loc:5;city=revenue:0,loc:2;upgrade=cost:40,terrain:water',
          },
          green: {
            ['G5'] => 'city=revenue:40;path=a:1,b:_0;'\
                      'city=revenue:40;path=a:3,b:_1;'\
                      'city=revenue:40;path=a:5,b:_2',
          },
          gray: {
            ['B8'] => 'city=revenue:20,loc:5.5;path=a:0,b:_0;path=a:5,b:_0',
            ['B12'] => 'city=revenue:30,loc:0;path=a:0,b:_0',
            ['E1'] => 'city=revenue:20,loc:2.5;path=a:3,b:_0;path=a:4,b:_0',
            ['E7'] => 'city=revenue:10,slots:2;'\
                      'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['F2'] => 'town=revenue:10,loc:4;path=a:4,b:_0;'\
                      'town=revenue:10,loc:1;path=a:5,b:_1',
            ['F10'] => 'town=revenue:10,loc:2;path=a:2,b:_0;path=a:5,b:0',
            ['K7'] => 'city=revenue:10,loc:3;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['B6'] => 'offboard=revenue:0;path=a:5,b:_0',
            ['B10'] => 'offboard=revenue:0;path=a:0,b:_0;path=a:5,b:_0',
            ['C1'] => 'offboard=revenue:0;path=a:5,b:_0',
            ['C3'] => 'offboard=revenue:0;path=a:0,b:_0;path=a:5,b:_0',
            ['C5'] => 'offboard=revenue:0;path=a:0,b:_0;path=a:5,b:_0;path=a:4,b:_0',
            ['L8'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L10'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L12'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L14'] => 'offboard=revenue:0;path=a:2,b:_0;path=a:3,b:_0',
            ['L16'] => 'offboard=revenue:0;path=a:2,b:_0',
          },
        }.freeze
      end
    end
  end
end
