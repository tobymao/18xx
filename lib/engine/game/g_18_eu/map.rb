# frozen_string_literal: true

require_relative 'tiles'

module Engine
  module Game
    module G18EU
      module Map
        include G18EU::Tiles

        LAYOUT = :flat

        LOCATION_NAMES = {
          'N17' => 'Bucharest',
          'N5' => 'Warsaw',
          'A6' => 'London',
          'A10' => 'Paris',
          'G2' => 'Hamburg',
          'G22' => 'Rome',
          'B17' => 'Lyon',
          'B19' => 'Marseille',
          'C8' => 'Brussels',
          'D3' => 'Amsterdam',
          'D7' => 'Cologne',
          'D13' => 'Strausburg',
          'D19' => 'Turin',
          'E6' => 'Dortmund',
          'E18' => 'Milan',
          'E20' => 'Genoa',
          'F9' => 'Frankfurt',
          'G12' => 'Munich',
          'H19' => 'Venice',
          'I18' => 'Trieste',
          'J5' => 'Berlin',
          'J7' => 'Dresden',
          'J11' => 'Prague',
          'M16' => 'Budapest',
          'B7' => 'Lille',
          'B13' => 'Dijon',
          'C4' => 'Rotterdam',
          'C6' => 'Antwerp',
          'C16' => 'Geneva',
          'D5' => 'Utrecht',
          'D15' => 'Basil',
          'E12' => 'Stuttgart',
          'F3' => 'Bremen',
          'F11' => 'Augsburg',
          'F21' => 'Florence',
          'G6' => 'Hannover',
          'G10' => 'Nuremberg',
          'G20' => 'Bologne',
          'H7' => 'Magdeburg',
          'I8' => 'Leipzig',
          'K4' => 'Stettin',
          'K12' => 'Brunn',
          'K14' => 'Vienna',
          'K16' => 'Semmering',
          'L5' => 'Thorn',
          'C20' => 'Nice',
          'E14' => 'Zürich',
          'H15' => 'Innsbruck',
          'I14' => 'Salzburg',
          'L15' => 'Pressburg',
          'M10' => 'Krakau',
        }.freeze

        HEXES = {
          red: {
            ['N17'] => 'offboard=revenue:yellow_30|brown_50;path=a:2,b:_0',
            ['N5'] => 'offboard=revenue:yellow_20|brown_30;path=a:1,b:_0',
            ['A6'] => 'offboard=revenue:yellow_40|brown_70;path=a:0,b:_0;path=a:5,b:_0',
            ['G2'] =>
                   'city=revenue:yellow_30|brown_50,loc:2;path=a:1,b:_0;path=a:_0,b:5;'\
                   'path=a:0,b:_0;path=a:_0,b:5;path=a:0,b:_0;path=a:_0,b:1',
            ['G22'] =>
                   'offboard=revenue:yellow_30|brown_50;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          blue: {
            ['D1'] =>
                     'offboard=revenue:10,visit_cost:0,route:optional;path=a:0,b:_0;icon=image:port;',
            %w[B21 E22 I20] =>
            'offboard=revenue:10,visit_cost:0,route:optional;path=a:3,b:_0;icon=image:port;',
          },
          yellow: {
            ['A10'] =>
                     'city=revenue:40,loc:15;city=revenue:40;path=a:4,b:_0;path=a:5,b:_1;label=P',
            ['J5'] =>
            'city=revenue:30;city=revenue:30;path=a:4,b:_0;path=a:1,b:_1;label=B-V',
            ['K14'] =>
            'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:3,b:_1;label=B-V',
            ['K16'] => 'path=a:1,b:3;upgrade=cost:60,terrain:mountain',
          },
          white: {
            %w[B17 C8 D3 D13 E18 G12 H19 J7 M16] =>
                     'city=revenue:0;label=Y',
            %w[B19 D7 D19 E6 E20 F9 I18 J11] => 'city=revenue:0',
            %w[B7
               B13
               C4
               C6
               C16
               D5
               D15
               E12
               F3
               F11
               F21
               G6
               G10
               G20
               H7
               I8
               K4
               K12
               L5] => 'town=revenue:0',
            %w[C20 E14 H15 I14 L15 M10] =>
            'town=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[A14
               A16
               C10
               D9
               D11
               F15
               G16
               I10
               I12
               J9
               J13
               K8
               L9] => 'upgrade=cost:60,terrain:mountain',
            %w[C18 D17 E16 F17 G18 H17 I16 J15] =>
            'upgrade=cost:120,terrain:mountain',
            %w[A8
               A12
               A18
               A20
               B9
               B15
               C12
               C14
               D21
               E4
               E8
               E10
               F5
               F7
               F13
               G4
               G8
               G14
               H3
               H5
               H9
               H11
               H13
               H21
               I4
               J3
               J17
               J19
               K6
               K10
               K18
               L7
               L11
               L13
               L17
               M6
               M8
               M12
               M14
               B11
               F19
               I6] => '',
          },
        }.freeze
      end
    end
  end
end
