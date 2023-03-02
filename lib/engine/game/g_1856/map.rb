# frozen_string_literal: true

module Engine
  module Game
    module G1856
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 3,
          '4' => 3,
          '5' => 2,
          '6' => 2,
          '7' => 7,
          '8' => 13,
          '9' => 13,
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
          '57' => 4,
          '58' => 3,
          '59' => 2,
          '63' => 4,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          '70' => 1,
          '120' => 1,
          '121' => 2,
          '122' => 1,
          '123' => 1,
          '124' => 1,
          '125' =>
          {
            'count' => 4,
            'color' => 'brown',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
          '126' => 1,
          '127' => 1,
        }.freeze

        LOCATION_NAMES = {
          'A20' => 'Detroit - Windsor',
          'A14' => 'Port Huron',
          'B13' => 'Sarnia',
          'F9' => 'Goderich',
          'H5' => 'Lake Huron',
          'K2' => 'Georgian Bay',
          'O2' => 'Canadian West',
          'Q8' => 'Lower Canada',
          'P17' => 'Buffalo',
          'F15' => 'London',
          'M4' => 'Barrie',
          'N11' => 'Toronto',
          'I12' => 'Kitchener',
          'I14' => 'Drumbo',
          'L15' => 'Hamilton',
          'N17' => 'Welland',
          'H15' => 'Woodstock',
          'J13' => 'Galt',
          'B19' => 'Chatham',
          'L13' => 'Burlington',
          'P9' => 'Oshawa',
          'F17' => 'St. Thomas',
          'O18' => 'Fort Erie',
          'C14' => 'Maudaumin',
          'D17' => 'Glencoe',
          'J11' => 'Guelph',
          'J15' => 'Brantford',
          'K8' => 'Orangeville',
          'O16' => 'Niagara Falls',
        }.freeze

        HEXES = {
          red: {
            ['A20'] =>
                     'offboard=revenue:yellow_30|brown_50|black_60;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
            ['A14'] => 'border=edge:4;icon=image:1856/tunnel;icon=image:1856/tunnel',
            ['B13'] =>
                   'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:5,b:_0,terminal:1;border=edge:1',
            ['H5'] =>
                   'offboard=revenue:yellow_30|brown_50|black_40;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                   'icon=image:port,sticky:1',
            ['K2'] =>
                   'offboard=revenue:yellow_20|brown_30;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                   'icon=image:port,sticky:1',
            ['N1'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,hide:1,groups:Canadian West;'\
                   'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;border=edge:5',
            ['O2'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,groups:Canadian West;'\
                   'path=a:0,b:_0,terminal:1;path=a:1,b:_0,terminal:1;path=a:5,b:_0,terminal:1;border=edge:2',
            ['Q8'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,groups:Lower Canada;'\
                   'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;border=edge:0',
            ['Q10'] =>
                   'offboard=revenue:yellow_20|brown_30|black_50,hide:1,groups:Lower Canada;'\
                   'path=a:2,b:_0,terminal:1;border=edge:3',
            ['P19'] =>
                   'offboard=revenue:yellow_30|brown_40,hide:1,groups:Buffalo;path=a:2,b:_0,terminal:1;border=edge:3'\
                   ';icon=image:1856/bridge;icon=image:1856/bridge',
            ['P17'] =>
                   'offboard=revenue:yellow_30|brown_40,groups:Buffalo;'\
                   'path=a:1,b:_0,terminal:1;path=a:2,b:_0,terminal:1;border=edge:0',
          },
          yellow: {
            %w[M4] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=B-L;future_label=label:Bar,color:brown',
            %w[F15] => 'city=revenue:30;path=a:0,b:_0;path=a:4,b:_0;label=B-L;future_label=label:Lon,color:brown',
            ['N11'] =>
            'city=revenue:30;city=revenue:30;label=T;path=a:1,b:_0;path=a:4,b:_1',
            %w[I12 N17] => 'city=revenue:0;city=revenue:0;label=OO',
            ['L15'] =>
            'city=revenue:0;city=revenue:0;label=OO;upgrade=cost:40,terrain:mountain',
          },
          blue: { ['N5'] => '' },
          gray: {
            ['F9'] =>
                        'town=revenue:yellow_30|brown_50|black_40;'\
                        'path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;icon=image:port,sticky:1',
          },
          white: {
            %w[H15 G12 I8 J13 D17 J11 J15 K8 O16] =>
                     'city=revenue:0',
            %w[B19 L13 P9] => 'city=revenue:0;future_label=label:L,color:brown',
            %w[C14 F17 O18] => 'city=revenue:0;future_label=label:L,color:brown;icon=image:port,sticky:1',
            ['N3'] => 'city=revenue:0;future_label=label:L,color:brown;upgrade=cost:40,terrain:water',
            %w[J9 K16 L9 M6 N9 H11] => 'town=revenue:0',
            %w[D19 H17 J5 M18] => 'town=revenue:0;icon=image:port,sticky:1',
            %w[I14 F13 M10] => 'town=revenue:0;town=revenue:0',
            %w[E18 H7 J17] =>
            'town=revenue:0;town=revenue:0;icon=image:port,sticky:1',
            %w[K10 K12 K14 M16 N15] => 'upgrade=cost:40,terrain:mountain',
            %w[N19 P7] => 'upgrade=cost:40,terrain:water',
            %w[L3
               B15
               B17
               B21
               C16
               C18
               C20
               D13
               D15
               E12
               E14
               E16
               F11
               G8
               G10
               G14
               G16
               G18
               H9
               H13
               I6
               I10
               I16
               I18
               J7
               K4
               K6
               K18
               L5
               L7
               L11
               L17
               M2
               M8
               M12
               N7
               O4
               O6
               O8
               O10
               P3
               P5] => 'blank',
          },
        }.freeze

        LAYOUT = :flat

        BROWN_OO_TILES = %w[64 65 66 67 68].freeze
        PORT_HEXES = %w[C14 D19 E18 F17 F9 H17 H7 H5 J17 J5 K2 M18 O18].freeze

        HAMILTON_HEX = 'L15'

        TUNNEL_TOKEN_HEX = 'A14'
        BRIDGE_TOKEN_HEX = 'P19'
      end
    end
  end
end
