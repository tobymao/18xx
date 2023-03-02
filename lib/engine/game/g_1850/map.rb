# frozen_string_literal: true

module Engine
  module Game
    module G1850
      module Map
        LAYOUT = :pointy

        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 4,
          '5' => 2,
          '6' => 2,
          '7' => 6,
          '8' => 20,
          '9' => 20,
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 2,
          '55' => 1,
          '56' => 1,
          '57' => 5,
          '58' => 4,
          '63' => 4,
          '69' => 1,
          '70' => 1,
          '128' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' =>
            'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;label=Chi',
          },
          '129' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:50;city=revenue:50,slots:2;path=a:0,b:_0;path=a:5,b:_0;path=a:1,b:_1;path=a:2,b:_1;'\
            'label=Chi',
          },
          '130' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=Chi',
          },
          '131' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:100,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Chi',
          },
          '132' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
            'label=M',
          },
          '133' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
            'label=M',
          },
          '134' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
            'label=M',
          },
          '135' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
            'label=P',
          },
          '138' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=P',
          },
          '141' => 1,
          '142' => 1,
          '143' => 1,
          '144' => 1,
          '145' => 1,
          '146' => 1,
          '147' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A2' => 'Northwest',
          'A10' => 'Mesabi Range',
          'B5' => 'Fargo',
          'B11' => 'Duluth',
          'C20' => 'Sault Ste. Marie',
          'D9' => 'Minneapolis & St. Paul',
          'E4' => 'Sioux Falls',
          'E18' => 'Green Bay',
          'F1' => 'West',
          'F13' => 'La Crosse',
          'G4' => 'Sioux City',
          'G16' => 'Madison',
          'G18' => 'Milwaukee',
          'H9' => 'Des Moines',
          'H11' => 'Cedar Rapids',
          'I4' => 'Omaha',
          'I12' => 'Rock Island',
          'I18' => 'Chicago',
          'J11' => 'Burlington & Quincy',
          'K4' => 'Topeka',
          'K6' => 'Kansas City',
          'K14' => 'Springfield, IL',
          'K20' => 'East',
          'L13' => 'St. Louis',
          'M2' => 'Southwest',
          'M8' => 'Springfield, MO',
          'M20' => 'South',

        }.freeze

        HEXES = {

          white: {
            %w[A4 A6 A8 A14 B3 B9 C2 C4 C6 C10 C12 C14 C18 D3 D5 D11 D15 D17 E2 E6 E8 E14 E16 F5 F7 F9
               F11 F17 G2 G6 G8 G14 H3 H7 H15 I6 I10 I14 J3 J7 J9 J13 J15 J17 J19 K2 K10 K16 K18 L3 L5 L7
               L15 L17 L19 M6 M10 M14 M16] => '',
            %w[B5 B11 E4 E18 G16 H9 K4 K14 M8] => 'city=revenue:0',
            %w[C16 D7 D13 F15 G10 H17 I2 I16 M4 M18] => 'town=revenue:0',
            %w[B13 C8 D19 E12 F3 G12 H5 H13 J5 K12 L9 L11] => 'upgrade=cost:40,terrain:water',
            ['I8'] => 'town=revenue:0;town=revenue:0',
            ['A12'] => 'upgrade=cost:60,terrain:mountain',
            %w[B7 I12 K8 M12] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[E10 J11] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:water',
            %w[F13 G4 I4] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[D9 K6 L13] => 'city=revenue:0;upgrade=cost:40,terrain:water;future_label=label:P,color:brown',
            ['I18'] => 'city=revenue:0;city=revenue:0;upgrade=cost:40,terrain:water;label=Chi',
          },

          yellow: {
            ['G18'] => 'city=revenue:20;upgrade=cost:40,terrain:water;path=a:1,b:_0;label=M',
            ['H11'] => 'city=revenue:20;path=a:1,b:_0;path=a:4,b:_0',
          },

          gray: {
            ['A10'] => 'town=revenue:yellow_30|brown_40|gray_60;path=a:0,b:_0;path=a:1,b:_0;'\
                       'path=a:4,b:_0;path=a:5,b:_0',
            ['I20'] => 'path=a:0,b:1',
          },

          red: {
            ['A2'] => 'offboard=revenue:yellow_30|brown_40;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                      'path=a:0,b:_0,lanes:2,terminal:1;icon=image:1850/GN_edge;icon=image:1850/MILW_edge;'\
                      'icon=image:1850/NP_edge',
            ['B1'] => 'path=a:3,b:4,a_lane:2.0;path=a:3,b:5,a_lane:2.1',
            ['C20'] => 'town=revenue:yellow_20|brown_40|gray_50;path=a:0,b:_0;path=a:1,b:_0;'\
                       'icon=image:1850/SOO_edge',
            ['F1'] => 'offboard=revenue:yellow_30|brown_40;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                      'icon=image:1850/UP_edge',
            ['K20'] => 'offboard=revenue:yellow_30|brown_40|gray_50;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;'\
                       'path=a:2,b:_0,terminal:1',
            ['M2'] => 'offboard=revenue:yellow_30|brown_40;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;'\
                      'icon=image:1850/KATY_edge',
            ['M20'] => 'offboard=revenue:yellow_20|brown_30|gray_40;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          },
        }.freeze
      end
    end
  end
end
