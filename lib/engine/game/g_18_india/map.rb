# frozen_string_literal: true

module Engine
  module Game
    module G18India
      module Map

        TILES = {
          # yellow tiles
          '9' => 41,
          '8' => 41,
          '7' => 6,
          '4' => 16,
          '58' => 16,
          '3' => 8,
          '235' => 2
          '57' => 3,
          '6' => 3,
          '5' => 3,

          # green tiles
          '80' => 4,
          '81' => 4,
          '82' => 4,
          '83' => 4,
          '141' => 3,
          '142' => 3,
          '143' => 3,
          '144' => 3,
          '619' => 2,
          '14' => 2,
          '15' => 2,
          '59' => 2,
          '205' => 2,
          '206' => 2,
          '12' => 2,
          '13' => 2,

          # brown tiles
          '544' => 2,
          '545' => 2,
          '546' => 2,
          '145' => 2,
          '146' => 2,
          '147' => 2,
          '611' => 6,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '984' => { 
            'count' => 2, 
            'color' => 'brown', 
            'code' => 'city=revenue:50;city=revenue:50;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },

          # gray tiles
          '60' => 1,
          '513' => 4,
          'GT6' => {
            'count' => 2, 
            'color' => 'gray', 
            'code' => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0', 
          },
          'IND1' => {
            'count' => 2, 
            'color' => 'gray', 
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=OO', 
          },
          
          # Ferry yellow / gray tiles
          'IF1' => { 'count' => 1, 'color' => 'yellow', 'code' => 'path=a:2,b:4;label=FERRY' }, 
          'IF2' => { 'count' => 1, 'color' => 'yellow', 'code' => 'path=a:0,b:2;label=FERRY' },

          # triple town tiles
          'IND2'=> {
            'count' => 2, 
            'color' => 'yellow',
            'code' => 'town=revenue:20; town=revenue:10; town=revenue:10;'\
            'path=a:1,b:_0;path=a:_0,b:2;path=a:0,b:_1;path=a:_1,b:4;path=a:3,b:_2;path=a:_2,b:5', 
          },
          'IND3'=> {
            'count' => 2, 
            'color' => 'yellow', 
            'code' => 'town=revenue:20; town=revenue:10; town=revenue:10;'\
            'path=a:1,b:_0;path=a:_0,b:4;path=a:0,b:_1;path=a:_1,b:5;path=a:1,b:_2;path=a:_2,b:3', 
          },
          'IND4'=> {
            'count' => 2, 
            'color' => 'yellow', 
            'code' => 'town=revenue:20; town=revenue:10; town=revenue:10;'\
            'path=a:2,b:_0;path=a:_0,b:5;path=a:0,b:_1;path=a:_1,b:3;path=a:1,b:_2;path=a:_2,b:4', 
          },
          'IND5'=> {
            'count' => 2, 
            'color' => 'yellow', 
            'code' => 'town=revenue:20; town=revenue:10; town=revenue:10;'\
            'path=a:2,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:1;path=a:4,b:_2;path=a:_2,b:5', 
          },
          'IND6'=> {
            'count' => 2, 
            'color' => 'yellow',
            'code' => 'town=revenue:20; town=revenue:10; town=revenue:10;'\
            'path=a2:,b:_0;path=a:_0,b:5;path=a1:,b:_1;path=a:_1,b:3;path=a:0,b:_2;path=a:_2,b:4',
          },
        }.freeze

        LOCATION_NAMES = {
          # TODO Add location names

          #Variable Value Cities
          'A16' => 'Karachi'
          'D3' => 'Lahore'
          'D23' => 'Mumbai'

        }.freeze

        HEXES = {
          # TODO list map hexes
          white: {
            %w[B9 B15 C8 C10 C12 C14 D5 D7 D9 D13 D15 D25 E2 E6 E8 E12 E14 E16 E20 E26 E28 F3 F7 F21 F31 F33 
               G2 G4 G10 G12 G14 G20 G24 G26 G28 H3 H5 H7 H9 H13 H19 H23 H27 H29 H33 H37 I6 
               I10 I12 I22 I24 I26 I32 I34 I36 I38 J9 J15 J19 J21 J29 J31 J35 K10 K16 K18 K20 K24 K26 K28 ] => '',
          } 
         
          red: {
            %w[A16 D3 D23] => '',
          }

          gray: {
            %w[B11 B13] => 'path=a:0,b:3',
          }
        
        }.freeze

      end
    end
  end
end
