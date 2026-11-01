# frozen_string_literal: true

module Engine
  module Game
    module G18Junta
      module Map2P
        # Rules summary 1.1: the 2-player game uses the smaller map on the back of the board.
        HEXES_2P = {
          orange: {
            ['A2'] => '',
          },
          white: {
            %w[D8 D14 E5] => '', # open terrain
            %w[B14 C11 E7 G3 G13 I9 J4 L8] => 'icon=image:18_junta/militia,large:2',
            %w[C15 G5 H8 K13] => 'town=revenue:0,style:hidden;label= ;icon=image:18_junta/farm;'\
                                 'upgrade=cost:25,terrain:swamp',
            %w[C13 D10 E13 F4 F12 I5 I11 J12 K5 K9] => 'city=revenue:0', # cities
            %w[C9 F8 H12] => 'town=revenue:0', # towns
            %w[F6 G9 H4 H10 I7 L10] => 'upgrade=cost:50,terrain:mountain', # mountains
            ['K11'] => 'upgrade=cost:50,terrain:mountain;icon=image:18_junta/militia,large:2',
            %w[B10 E9 G11 H6 J6 J10] => 'town=revenue:0,style:hidden;label= ;icon=image:18_junta/farm,loc:15;'\
                                        'upgrade=cost:75,terrain:mountain|swamp',
            %w[D12 K7] => 'town=revenue:0;upgrade=cost:50,terrain:mountain', # towns on mountains
            ['J8'] => 'city=revenue:0;upgrade=cost:50,terrain:mountain', # home city of Montañera, on a mountain
            ['E11'] => 'label=L;stripes=color:blue;upgrade=cost:100,terrain:river', # Laguna
          },
          green: {
            ['G7'] => 'city=revenue:30,slots:2;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=V',
            ['L6'] => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=M',
          },
          brown: {
            ['F10'] => 'city=revenue:yellow_40|brown_60,slots:2;path=a:1,b:_0;path=a:5,b:_0;label=S',
          },
          gray: {
            ['B12'] => 'path=a:1,b:3;path=a:3,b:6',
          },
          red: {
            ['A13'] => 'offboard=revenue:yellow_40|brown_60;path=a:4,b:_0;path=a:5,b:_0;future_label=label:80,color:red',
            ['D6'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                      'future_label=label:50,color:red',
            ['L12'] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                       'future_label=label:40,color:red',
            ['I3'] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;'\
                      'future_label=label:50,color:red',
          },
        }.freeze

        LOCATION_NAMES_2P = {
          'L6' => 'Monterrey',
          'G7' => 'Valle Verde',
          'F10' => 'San Isidro',
          'A13' => 'Navidad',
          'D6' => 'Don Ramón',
          'I3' => 'San Miguel',
          'L12' => 'Puerto Viejo',
          'E11' => 'Laguna',
          'A2' => 'NEUTRAL',
        }.freeze

        PARAMILITARY_HEXES_2P = %w[B14 C11 E7 G3 G13 I9 J4 K11 L8].freeze

        # Rules summary 6.5 on the 2-player map.
        DICTATORSHIP_BORDER_TILES_2P = {
          'A13' => 'offboard=revenue:80;path=a:4,b:_0;path=a:5,b:_0', # Navidad
          'D6' => 'offboard=revenue:50;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          'L12' => 'offboard=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0', # Puerto Viejo
          'I3' => 'offboard=revenue:50;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0', # San Miguel
        }.freeze
      end
    end
  end
end
