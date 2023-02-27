# frozen_string_literal: true

module Engine
  module Game
    module G18VA
      module Map
        TILE_TYPE = :lawson

        TILES = {
          # yellow dits
          '4' => 4,
          '58' => 4,

          # yellow plain
          '7' => 4,
          '8' => 12,
          '9' => 12,

          # yellow city
          '5' => 4,
          '6' => 4,
          '57' => 4,

          # green plain
          '80' => 3,
          '81' => 3,
          '82' => 4,
          '83' => 4,

          # green dits
          '141' => 2,
          '142' => 2,
          '143' => 1,
          '144' => 1,

          # green city
          '14' => 4,
          '15' => 6,

          # brown plain
          '544' => 2,
          '545' => 2,
          '546' => 2,

          # brown city
          '63' => 4,
          '170' => 3,
          '170was' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;label=Was;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0',
          },
          '170ric' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;label=Ric;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:0,b:_0',
          },

          # washington
          '172' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:2;label=Was;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0',
          },

          # richmond
          '171' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=Ric;'\
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'H1' => 'Philadelphia',
          'E2' => 'Hagerstown',
          'F3' => 'Harper\'s Ferry',
          'H3' => 'Baltimore',
          'C4' => 'Cumberland',
          'G4' => 'Washington',
          'F5' => 'Alexandria',
          'H5' => 'Annapolis',
          'A6' => 'Grafton',
          'F7' => 'Fredericksburg',
          'C8' => 'Staunton',
          'E8' => 'Gordonsville',
          'D9' => 'Charlottesville',
          'F11' => 'Richmond',
          'A12' => 'Roanoke',
          'C12' => 'Lynchburg',
          'F13' => 'Petersburg',
          'H13' => 'Newport News',
          'B15' => 'Greensboro',
          'H15' => 'Norfolk',
          'F17' => 'Rocky Mount',
        }.freeze

        HEXES = {
          white: {
            %w[F1 G2 D3 D5 C6 E6 D7 F9 E10 C10 G10 D11 E12 D13 C14 E14 D15 F15] => '',
            %w[G14] => 'border=edge:3,type:impassable;border=edge:4,type:impassable',
            %w[G12] => 'border=edge:0,type:impassable;border=edge:1,type:impassable',
            %w[G6] => 'border=edge:1,type:impassable;border=edge:4,type:impassable',
            %w[E4] => 'border=edge:4,type:impassable',
            %w[B5 B7 B9 B11 B13] => 'town=revenue:0;icon=image:18_co/mine,sticky:1',
            %w[C4 C8 C12 D9 E2 E8] => 'city=revenue:0',
            %w[F7] => 'city=revenue:0;border=edge:4,type:impassable',
            %w[F3] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:1,type:impassable',
            %w[F13] => 'city=revenue:0;future_label=color:brown,label:P;border=edge:4,type:impassable',
            %w[H3] => 'city=revenue:0;future_label=color:brown,label:P',
            %w[F5] => 'city=revenue:0;future_label=color:brown,label:P;border=edge:3,type:impassable',
            %w[G4] => 'city=revenue:0;future_label=color:brown,label:Was',
            %w[F11] => 'city=revenue:0;future_label=color:brown,label:Ric',
          },
          yellow: {
            %w[H5] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0;border=edge:1,type:impassable',
            %w[H13] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0;'\
                       'border=edge:0,type:impassable;border=edge:1,type:impassable',
            %w[H15] => 'city=revenue:20;path=a:2,b:_0;path=a:5,b:_0;border=edge:3,type:impassable',
          },
          red: {
            # Off map cities
            ['H1'] => 'city=slots:2,revenue:yellow_40|brown_70,groups:OFFBOARD;path=a:0,b:_0,terminal:1',
            ['B15'] => 'city=slots:1,revenue:yellow_20|brown_40,groups:OFFBOARD;path=a:4,b:_0,terminal:1',
            ['F17'] => 'city=slots:1,revenue:yellow_30|brown_50,groups:OFFBOARD;path=a:3,b:_0,terminal:1',
          },
          gray: {
            # CMD
            ['A6'] => 'city=slots:2,revenue:20,groups:CMD;icon=image:18_co/mine,visit_cost:0;'\
                      'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A12'] => 'city=slots:2,revenue:20,groups:CMD;icon=image:18_co/mine;'\
                       'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
          },
          blue: {
            ['I4'] =>
                        'offboard=revenue:yellow_30|brown_20,visit_cost:0,route:optional,groups:PORT;'\
                        'path=a:2,b:_0;icon=image:port',
            ['I6'] =>
                        'offboard=revenue:yellow_20|brown_10,visit_cost:0,route:optional,groups:PORT;'\
                        'path=a:2,b:_0;icon=image:port',
            ['I14'] =>
                        'offboard=revenue:yellow_20|brown_40,visit_cost:0,route:optional,groups:PORT;'\
                        'path=a:2,b:_0;icon=image:port',
            ['I16'] =>
                        'offboard=revenue:yellow_30|brown_50,visit_cost:0,route:optional,groups:PORT;'\
                        'path=a:2,b:_0;icon=image:port',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
