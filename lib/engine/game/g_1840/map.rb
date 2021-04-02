# frozen_string_literal: true

module Engine
  module Game
    module G1840
      module Map
        LAYOUT = :pointy

        TILES = {
          '1' => 1,
          '2' => 1,
          '7' => 5,
          '8' => 14,
          '9' => 13,
          '3' => 4,
          '58' => 4,
          '4' => 4,
          '5' => 4,
          '6' => 4,
          '57' => 4,
          '201' => 2,
          '202' => 2,
          '621' => 2,
          '55' => 1,
          '56' => 1,
          '69' => 1,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '14' => 4,
          '15' => 4,
          '619' => 4,
          '208' => 2,
          '207' => 2,
          '622' => 2,
          '611' => 7,
          '216' => 3,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '70' => 1,
        }.freeze

        HEXES = {
          gray: {
            ['B7'] => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0',
            ['B9'] => 'town=revenue:20;path=a:5,b:_0',
            ['G2'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            %w[C22 I22] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
            ['L7'] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
            %w[I30 D29] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            ['G30'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
            ['E28'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0',
            ['G8'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;town=revenue:20;path=a:2,b:_1;path=a:3,b:_1',
            ['G10'] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0;town=revenue:20;path=a:2,b:_1;path=a:3,b:_1',
            ['B19'] => 'town=revenue:30;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          white: {
            %w[C4 C6 C8 C18 C24 D3 D5 D11 D19 D23 D25 D27 E2 E8 E10 E14 E16 F5 F9 F25 F27 G4 G16 G26 H7 H9 H13 H27 H29
               I4 I6 I8 I14 I18 I24 I26 J17 J19 J23 J25 J29 K6 K8 K12 K14 K18 K20 K24] => '',
            %w[C12 D15 E4 E2 E24 E26 F3 F11 F15 G14 G18 G20 G22 G28 H15 H25 I20 I28 J21 K10 K16 K26 K28] =>
            'city=revenue:0',
            ['C28'] => 'upgrade=cost:40,terrain:water',
            %w[I10 E18 F17] =>
            'city=revenue:0;city=revenue:0',
            %w[C10 E12 E22 F23 G6 J9 J15] => 'city=revenue:0;upgrade=cost:20;frame=color:orange',
            %w[D9 D7 E6 F7 H5 C16 C14 D13 F13 G12 I12 J11 J13 J7 J5 J3 J13 I16 H17 H19 H21 H23 C20
               D21] => 'upgrade=cost:20;frame=color:orange',
          },
          yellow: {

          },

          red: {
            %w[E20 F19 F21] => '',
            ['L9'] =>
            'path=a:5,b:2,a_lane:2.0;path=a:5,b:3,a_lane:2.1',
            ['L11'] =>
            'path=a:0,b:2,a_lane:2.0;path=a:0,b:3,a_lane:2.1',
            ['M10'] =>
             'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0,lanes:2;'\
              'path=a:3,b:_0,lanes:2;border=edge:1;city=revenue:0,slots:2',
            ['L15'] =>
            'path=a:5,b:2,a_lane:2.0;path=a:5,b:3,a_lane:2.1',
            ['L17'] =>
            'path=a:0,b:2,a_lane:2.0;path=a:0,b:3,a_lane:2.1',
            ['M16'] =>
                'offboard=revenue:yellow_20|green_30|brown_40|gray_50;'\
                 'path=a:2,b:_0,lanes:2;path=a:3,b:_0,lanes:2;border=edge:1;city=revenue:0,slots:2',
            ['L27'] =>
                'path=a:5,b:2,a_lane:2.0;path=a:5,b:3,a_lane:2.1',
            ['L29'] =>
                'path=a:2,b:0',
            ['M28'] =>
                'offboard=revenue:yellow_20|green_30|brown_40|gray_50;'\
                 'path=a:2,b:_0,lanes:2;path=a:3,b:_0;border=edge:1;city=revenue:0,slots:2',
            ['K4'] =>
               'offboard=revenue:yellow_30|green_50|brown_60|gray_80;'\
                'path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;city=revenue:0,slots:2',
            ['B29'] =>
                'offboard=revenue:yellow_30|green_40|brown_60|gray_70;'\
                 'path=a:0,b:_0',
            ['B21'] =>
               'path=a:0,b:3;border=edge:4',
            ['B23'] =>
               'path=a:5,b:2;border=edge:1',
            ['A22'] =>
                'offboard=revenue:yellow_20|green_30|brown_40|gray_50;'\
                 'path=a:0,b:_0;path=a:5,b:_0;border=edge:1;city=revenue:0,slots:2',
            ['C2'] =>
                 'path=a:2,b:4,a_lane:2.0;path=a:2,b:5,a_lane:2.1',
            ['B3'] =>
                 'path=a:1,b:5',
            ['B1'] =>
                 'offboard=revenue:yellow_30|green_40|brown_60|gray_70;'\
                  'path=a:5,b:_0,lanes:2;path=a:4,b:_0;city=revenue:0,slots:2',
            ['J1'] =>
                 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;'\
                  'path=a:4,b:_0,track:narrow;city=revenue:0 ',

            ['B17'] =>
                   'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0,track:narrow;' \
                   'path=a:1,b:_1,track:narrow;path=a:4,b:_2,track:narrow;',
            ['B13'] =>
                   'city=revenue:30,slots:2;path=a:0,b:_0;path=a:5,b:_0;' \
                   'path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow;',
            ['B15'] => 'path=a:1,b:4,track:narrow',
            ['B11'] => 'path=a:0,b:4,track:narrow',
            ['H3'] =>
                 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;'\
                  'path=a:3,b:_0;path=a:5,b:_0;path=a:4,b:_0,track:narrow;city=revenue:0,slots:2',
          },

          lilac: {
            %w[D17 C26 H11 G24 J27] => '',
          },
        }.freeze
      end
    end
  end
end
