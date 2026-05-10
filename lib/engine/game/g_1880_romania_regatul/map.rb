# frozen_string_literal: true

require_relative '../g_1880_romania/map'

module Engine
  module Game
    module G1880RomaniaRegatul
      module Map
        include G1880Romania::Map

        LAYOUT = :pointy
        AXES = { x: :letter, y: :number }.freeze

        LOCATION_NAMES = {
          'Q1' => 'Czernowitz',
          'P2' => 'Cluj-Napoca',
          'R2' => 'Suceava / Botoșani',
          'V2' => 'Moskova',
          'Q3' => 'Iași',
          'T4' => 'Bacău',
          'V4' => 'Vaslui',
          'X4' => 'Chișinău',
          'Q5' => 'Miercurea Ciuc / Targu Oena',
          'S5' => 'Onesti',
          'U5' => 'Birlad',
          'T6' => 'Focșani',
          'I7' => 'Vienna Budapesta',
          'O7' => 'Campulun',
          'W7' => 'Braila / Galati',
          'Y7' => 'Tulcea',
          'H8' => 'Petrosani / Târgu Jiu',
          'L8' => 'Râmnicu Vâlcea',
          'N8' => 'Pitești',
          'P8' => 'Tîrgoviște / Ploiești',
          'T8' => 'Buzău',
          'Z8' => 'Odesa',
          'G9' => 'Drobeta-Turnu Severin',
          'Q9' => 'Burcurești',
          'U9' => 'Slobozia / Fetesti',
          'Y9' => 'Năvodari',
          'J10' => 'Craiova',
          'L10' => 'Slatina',
          'T10' => 'Calarasi',
          'X10' => 'Constanta',
          'Z10' => 'Marea Neagră',
          'G11' => 'Sofia',
          'I11' => 'Băilești',
          'K11' => 'Dunărea',
          'O11' => 'Alexandria',
          'Q11' => 'Girgiu',
          'S11' => 'Instanbul',
          'W11' => 'Varna',
        }.freeze

        def map_optional_hexes
          white = {
            # no cities or towns
            %w[S1 T2 S3 W5 V6 U7 J8 R8 X8 I9 K9 M9 O9 S9 H10 N10 P10 R10 K11 M11] => '',
            %w[P4 R4 R6] => 'upgrade=cost:40,terrain:mountain',
            ['Q7'] => 'upgrade=cost:30,terrain:mountain',
            %w[K7 M7 S7] => 'upgrade=cost:20,terrain:mountain',
            %w[V8 W9] => 'upgrade=cost:20,terrain:water',
            ['V10'] => 'upgrade=cost:10,terrain:water',

            # town
            %w[V4 U5 Y9 L10 O11] => 'town=revenue:0',
            %w[I11 Q11] => 'town=revenue:0;icon=image:port',
            ['S5'] => 'town=revenue:0;upgrade=cost:40,terrain:mountain',
            ['O7'] => 'town=revenue:0;upgrade=cost:20,terrain:mountain',
            ['G9'] => 'town=revenue:0;upgrade=cost:20,terrain:mountain;icon=image:port',

            # double towns
            ['U9'] => 'town=revenue:0;town=revenue:0',
            ['Q5'] => 'town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain',

            # city
            %w[U3 T4 N8 T8 J10 X10] => 'city=revenue:0',
            ['Q1'] => 'city=revenue:0;label=T',
            ['Y7'] => 'city=revenue:0;label=T;icon=image:port',
            ['Q3'] => 'city=revenue:0;upgrade=cost:40,terrain:mountain',

            # town and city
            ['L8'] => 'town=revenue:0;city=revenue:0',
            ['T10'] => 'town=revenue:0;city=revenue:0;icon=image:port',
            ['T6'] => 'town=revenue:0;city=revenue:0;upgrade=cost:30,terrain:mountain',

            # double city
            ['P8'] => 'city=revenue:0;city=revenue:0',
            ['W7'] => 'city=revenue:0;city=revenue:0;upgrade=cost:10,terrain:water;icon=image:port',
            ['Q9'] => 'city=revenue:20;city=revenue:20;path=a:1,b:_0;path=a:4,b:_1;label=B',

            # double town and city
            %w[R2 H8] => 'town=revenue:0;city=revenue:0;town=revenue:0;city=revenue:0',
          }
          blue = {
            ['Z8'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:1,b:_0;path=a:2,b:_0',
            ['Z10'] => 'city=revenue:yellow_20|green_30|brown_40|gray_40;path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1',
          }
          red = {
            ['P2'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0;path=a:4,b:_0',
            ['V2'] => 'city=revenue:yellow_20|green_30|brown_50|gray_60;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['X4'] => 'city=revenue:yellow_20|green_60|brown_30|gray_40;path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1',
            ['I7'] => 'city=revenue:yellow_20|green_30|brown_50|gray_70;path=a:0,b:_0,terminal:1;path=a:4,b:_0,terminal:1;'\
                      'path=a:5,b:_0,terminal:1',
            ['G11'] => 'city=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['S11'] => 'offboard=revenue:yellow_10|green_20|brown_40|gray_50;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            ['W11'] => 'offboard=revenue:yellow_10|green_20|brown_30|gray_40;path=a:2,b:_0;path=a:3,b:_0',
          }
          {
            white: white,
            blue: blue,
            red: red,
          }.freeze
        end
      end
    end
  end
end
