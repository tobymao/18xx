# frozen_string_literal: true

module Engine
  module Game
    module G22Mars
      module Map
        TILES = {
          '3' => 2,
          '4' => 2,
          '7' => 2,
          '8' => 2,
          '9' => 2,
          '58' => 2,
          '19' => 1,
          '20' => 1,
          '23' => 1,
          '24' => 1,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '624' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '44' => 1,
          '47' => 1,
          'M1' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
          },
          'M2' => {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:2,b:_0',
          },
          'M3' => {
            'count' => 3,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:3,b:_0',
          },
          'M4' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'M5' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'M6' => {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'M7' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          'M8' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'M9' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'M10' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'M11' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'M12' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'M13' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'M14' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:40,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'M15' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:40,slots:3;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'M16' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'CC1' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'label=CC;city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:4,b:_1',
          },
          'CC2' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'label=CC;city=revenue:20,loc:0;city=revenue:20,loc:3;path=a:5,b:_0;path=a:4,b:_1',
          },
          'CC3' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'label=CC;city=revenue:20;city=revenue:20;path=a:0,b:_0;path=a:3,b:_1',
          },
          'CC4' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30,loc:0;city=revenue:30,slots:2,loc:2;'\
                      'path=a:0,b:_0;path=a:4,b:_0;path=a:1,b:_1;path=a:3,b:_1',
          },
          'CC5' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30,loc:3.5;city=revenue:30,slots:2,loc:0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:5,b:_1',
          },
          'CC6' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30;city=revenue:30,slots:2;'\
                      'path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:5,b:_1',
          },
          'CC7' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30;city=revenue:30,slots:2;'\
                      'path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:_1;path=a:4,b:_1',
          },
          'CC8' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30,slots:2;city=revenue:30;'\
                      'path=a:3,b:_0;path=a:5,b:_0;path=a:0,b:_1;path=a:4,b:_1',
          },
          'CC9' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30,slots:2;city=revenue:30;'\
                      'path=a:1,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:5,b:_1',
          },
          'CC10' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30,slots:2;city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;path=a:1,b:_1;path=a:3,b:_1',
          },
          'CC11' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=CC;city=revenue:30,slots:2;city=revenue:30;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_1;path=a:5,b:_1',
          },
          'CC12' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'label=CC;city=revenue:40,slots:2,loc:0;city=revenue:40,slots:2,loc:3;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1;path=a:5,b:_0',
          },
          'CC13' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=CC;city=revenue:40,slots:2;city=revenue:40,slots:2;'\
                      'path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_1;path=a:4,b:_1;path=a:5,b:_1',
          },
          'CC14' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=CC;city=revenue:40,slots:2,loc:0;city=revenue:40,slots:2,loc:3;'\
                      'path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:4,b:_1',
          },
          'CC15' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'label=CC;city=revenue:40,slots:2,loc:0;city=revenue:40,slots:2,loc:3;'\
                      'path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:3,b:_1;path=a:4,b:_1',
          },
          'CC16' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'label=CC;city=revenue:50,slots:2,loc:0;city=revenue:50,slots:2,loc:3;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1;path=a:5,b:_0;path=a:_0,b:_1',
          },
          'CC17' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'label=CC;city=revenue:50,slots:2,loc:0;city=revenue:50,slots:2,loc:3;'\
                      'path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1',
          },
          'CC18' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'label=CC;city=revenue:50,slots:2,loc:0.5;city=revenue:50,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:3,b:_1;path=a:4,b:_1;path=a:5,b:_1',
          },
          'AAP' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'label=AAP;town=revenue:30;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'D13' => 'Mining Area Gamma',
          'H15' => 'Mining Area Alpha',
        }.freeze

        HEXES = {
          white: {
            # Board 1
            ['C6'] => 'city=revenue:20;city=revenue:20;label=CC',
            ['C8'] => 'city=revenue:10',
            ['D5'] => '',
            ['D7'] => 'town',
            ['D9'] => 'city=revenue:10',
            ['E6'] => '',
            ['E8'] => 'city=revenue:20;city=revenue:20;label=CC',
            # Board 2
            ['C12'] => 'city=revenue:10',
            ['C14'] => 'city=revenue:10',
            ['D11'] => 'city=revenue:10',
            ['D13'] => 'frame=color:#00aa00',
            ['D15'] => 'town',
            ['E12'] => '',
            ['E14'] => 'city=revenue:10',
            # Board 3
            ['G6'] => '',
            ['G8'] => 'city=revenue:10',
            ['H5'] => 'city=revenue:20;city=revenue:20;label=CC',
            ['H7'] => 'city=revenue:20;city=revenue:20;label=CC',
            ['H9'] => 'town',
            ['I6'] => '',
            ['I8'] => 'city=revenue:10',
            # Board 4
            ['G12'] => '',
            ['G14'] => 'city=revenue:10',
            ['H11'] => 'city=revenue:20;city=revenue:20;label=CC',
            ['H13'] => 'city=revenue:10',
            ['H15'] => 'frame=color:#aa0000',
            ['I12'] => 'town',
            ['I14'] => 'city=revenue:10',
          },
          gray: {
            ['A4'] => 'path=a:4,b:0,lanes:5',
            %w[A6 A8 A10 A12 A14 K6 K8 K10 K12 K14] => 'path=a:3,b:0,lanes:5',
            ['A16'] => 'path=a:3,b:5,lanes:5',
            ['B3'] => 'path=a:5,b:1,a_lane:4.0,b_lane:5.4;'\
                       'path=a:5,b:1,a_lane:4.1,b_lane:5.3
                       path=a:4,b:1,a_lane:3.0,b_lane:5.2;'\
                       'path=a:4,b:1,a_lane:3.1,b_lane:5.1;'\
                       'path=a:4,b:1,a_lane:3.2,b_lane:5.0',
            ['B5'] => 'path=a:5,b:4,b_lane:4.0;'\
                      'path=a:0,b:4,a_lane:4.3,b_lane:4.1;'\
                      'path=a:0,b:4,a_lane:4.2,b_lane:4.2;'\
                      'path=a:0,b:4,a_lane:4.1,b_lane:4.3',
            ['B7'] => 'path=a:4,b:3,b_lane:4.0;'\
                      'path=a:5,b:3,b_lane:4.1;'\
                      'path=a:0,b:3,b_lane:4.2',
            ['B9'] => 'path=a:4,b:3',
            ['B11'] => 'path=a:0,b:5',
            ['B13'] => 'path=a:5,b:0,b_lane:4.3;'\
                       'path=a:4,b:0,b_lane:4.2;'\
                       'path=a:3,b:0,b_lane:4.1',
            ['B15'] => 'path=a:4,b:5,b_lane:4.3;'\
                       'path=a:3,b:5,a_lane:4.0,b_lane:4.2;'\
                       'path=a:3,b:5,a_lane:4.1,b_lane:4.1;'\
                       'path=a:3,b:5,a_lane:4.2,b_lane:4.0',
            ['B17'] => 'path=a:4,b:2,a_lane:4.3,b_lane:5.0;'\
                       'path=a:4,b:2,a_lane:4.2,b_lane:5.1;'\
                       'path=a:5,b:2,a_lane:3.2,b_lane:5.2;'\
                       'path=a:5,b:2,a_lane:3.1,b_lane:5.3;'\
                       'path=a:5,b:2,a_lane:3.0,b_lane:5.4',
            ['C2'] => 'path=a:5,b:1,lanes:3',
            ['C4'] => 'path=a:1,b:4,lanes:4;'\
                      'path=a:0,b:2,b_lane:4.3;'\
                      'path=a:5,b:2,b_lane:4.2',
            %w[C10 G10] => 'path=a:0,b:3;'\
                           'path=a:4,b:5',
            ['C16'] => 'path=a:2,b:5,lanes:4;'\
                       'path=a:3,b:1,b_lane:4.0;'\
                       'path=a:4,b:1,b_lane:4.1;',
            ['C18'] => 'path=a:4,b:2,lanes:3',
            %w[D1 H1] => '',
            ['D3'] => 'path=a:1,b:4,lanes:4;'\
                      'path=a:0,b:2,b_lane:3.2;'\
                      'path=a:5,a_lane:2.0,b:2,b_lane:3.1;'\
                      'path=a:5,a_lane:2.1,b:2,b_lane:3.0',
            ['D17'] => 'path=a:2,b:5,lanes:4;'\
                       'path=a:3,b:1,b_lane:3.0;'\
                       'path=a:4,b:1,a_lane:2.1,b_lane:3.1;'\
                       'path=a:4,b:1,a_lane:2.0,b_lane:3.2',
            ['D19'] => '',
            ['E2'] => 'path=a:1,b:4,lanes:4',
            ['E4'] => 'path=a:1,b:2,b_lane:2.1;'\
                      'path=a:0,b:2,b_lane:2.0',
            %w[E10 I10] => 'path=a:0,b:3;'\
                           'path=a:1,b:2',
            ['E16'] => 'path=a:2,b:1,b_lane:2.0;'\
                       'path=a:3,b:1,b_lane:2.1',
            ['E18'] => 'path=a:2,b:5,lanes:4',
            ['F1'] => 'path=a:1,b:5,lanes:4',
            ['F3'] => '',
            %w[F5 F11] => 'path=a:1,b:5',
            %w[F7 F13] => 'path=a:2,b:4;'\
                          'path=a:1,b:5',
            %w[F9 F15] => 'path=a:2,b:4',
            ['F17'] => '',
            ['F19'] => 'path=a:2,b:4,lanes:4',
            ['G2'] => 'path=a:2,b:5,lanes:4',
            ['G4'] => 'path=a:0,b:4,b_lane:2.1;'\
                      'path=a:5,b:4,b_lane:2.0',
            ['G16'] => 'path=a:3,b:5,b_lane:2.0;'\
                       'path=a:4,b:5,b_lane:2.1',
            ['G18'] => 'path=a:1,b:4,lanes:4',
            ['H3'] => 'path=a:2,b:5,lanes:4;'\
                      'path=a:0,b:4,b_lane:3.0;'\
                      'path=a:1,b:4,a_lane:2.1,b_lane:3.1;'\
                      'path=a:1,b:4,a_lane:2.0,b_lane:3.2',
            ['H17'] => 'path=a:1,b:4,lanes:4;'\
                       'path=a:2,b:5,a_lane:2.1,b_lane:3.0;'\
                       'path=a:2,b:5,a_lane:2.0,b_lane:3.1;'\
                       'path=a:3,b:5,b_lane:3.2;',
            ['H19'] => '',
            ['I2'] => 'path=a:5,b:1,lanes:3',
            ['I4'] => 'path=a:2,b:5,lanes:4;'\
                      'path=a:1,b:4,b_lane:4.1;'\
                      'path=a:0,b:4,b_lane:4.0',
            ['I16'] => 'path=a:1,b:4,lanes:4;'\
                       'path=a:2,b:5,b_lane:4.2;'\
                       'path=a:3,b:5,b_lane:4.3',
            ['I18'] => 'path=a:4,b:2,lanes:3',
            ['J3'] => 'path=a:1,b:5,a_lane:4.3,b_lane:5.0;'\
                      'path=a:1,b:5,a_lane:4.2,b_lane:5.1;'\
                      'path=a:2,b:5,a_lane:3.2,b_lane:5.2;'\
                      'path=a:2,b:5,a_lane:3.1,b_lane:5.3;'\
                      'path=a:2,b:5,a_lane:3.0,b_lane:5.4',
            ['J5'] => 'path=a:1,b:2,b_lane:4.3;'\
                      'path=a:0,b:2,a_lane:3.0,b_lane:4.2;'\
                      'path=a:0,b:2,a_lane:3.1,b_lane:4.1;'\
                      'path=a:0,b:2,a_lane:3.2,b_lane:4.0',
            ['J7'] => 'path=a:2,b:3,b_lane:3.2;'\
                      'path=a:1,b:3,b_lane:3.1;'\
                      'path=a:0,b:3,b_lane:3.0',
            ['J9'] => 'path=a:2,b:3',
            ['J11'] => 'path=a:1,b:0',
            ['J13'] => 'path=a:1,b:0,b_lane:3.0;'\
                       'path=a:2,b:0,b_lane:3.1;'\
                       'path=a:3,b:0,b_lane:3.2',
            ['J15'] => 'path=a:2,b:1,b_lane:4.0;'\
                       'path=a:3,b:1,a_lane:3.2,b_lane:4.1;'\
                       'path=a:3,b:1,a_lane:3.1,b_lane:4.2;'\
                       'path=a:3,b:1,a_lane:3.0,b_lane:4.3',
            ['J17'] => 'path=a:1,b:4,a_lane:3.2,b_lane:5.0;'\
                       'path=a:1,b:4,a_lane:3.1,b_lane:5.1;'\
                       'path=a:1,b:4,a_lane:3.0,b_lane:5.2;'\
                       'path=a:2,b:4,a_lane:4.1,b_lane:5.3;'\
                       'path=a:2,b:4,a_lane:4.0,b_lane:5.4',
            ['K4'] => 'path=a:2,b:0,lanes:5',
            ['K16'] => 'path=a:3,b:1,lanes:5',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
