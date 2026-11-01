# frozen_string_literal: true

module Engine
  module Game
    module G18Junta
      module Map
        TILES = {
          '3' => 2,
          '4' => 2,
          '5' => 2,
          '6' => 4,
          '7' => 2,
          '8' => 4,
          '9' => 4,

          '14' => 2,
          '15' => 2,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 2,
          '24' => 2,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 4,
          '58' => 2,
          '205' => 1,
          '206' => 1,
          '448' => 2,
          '449' => 2,
          '452' => 1,
          '453' => 1,

          'J09' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },

          'J10' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;label=M;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },

          'J11' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;label=V;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },

          'J12' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },

          'J13' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:80,slots:3;label=M;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },

          'J14' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:70,slots:3;label=V;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },

          'J15' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:brown_70|diesel_80,slots:3;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=S',
          },

          # Farms use the engine's native swamp terrain (the swamp icon is drawn on the upgrade cost);
          # the terrain also ties the farm discount of Private (J) to these tiles and hexes.
          'J01' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:yellow_10|diesel_20,style:hidden,visit_cost:0;'\
                      'junction;path=a:0,b:_0;path=a:_0,b:2;label= ;'\
                      'icon=image:18_junta/farm,large:2;upgrade=cost:25,terrain:swamp',
          },
          'J02' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:yellow_10|diesel_20,style:hidden,visit_cost:0;'\
                      'junction;path=a:0,b:_0;path=a:1,b:_0;label= ;'\
                      'icon=image:18_junta/farm,large:2;upgrade=cost:25,terrain:swamp',
          },
          'J03' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'town=revenue:yellow_10|diesel_20,style:hidden,visit_cost:0;'\
                      'path=a:0,b:_0;path=a:3,b:_0;label= ;'\
                      'icon=image:18_junta/farm,large:2;upgrade=cost:25,terrain:swamp',
          },
          'J04' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:green_20|diesel_40,style:hidden,visit_cost:0;'\
                      'path=a:0,b:_0;path=a:3,b:_0;path=a:2,b:_0;label= ;'\
                      'icon=image:18_junta/farm,large:2;upgrade=cost:25,terrain:swamp',
          },
          'J05' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:green_20|diesel_40,style:hidden,visit_cost:0;'\
                      'path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label= ;'\
                      'icon=image:18_junta/farm,large:2;upgrade=cost:25,terrain:swamp',
          },
          'J06' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:brown_30|diesel_60,style:hidden,visit_cost:0;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:1,b:_0;'\
                      'label= ;icon=image:18_junta/farm,large:2;upgrade=cost:25,terrain:swamp',
          },
          'J07' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:brown_30|diesel_60,style:hidden,visit_cost:0;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;'\
                      'label= ;icon=image:18_junta/farm,large:2;upgrade=cost:25,terrain:swamp',
          },

          'J08' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'town=revenue:gray_40|diesel_80,style:hidden,visit_cost:0,terrain:swamp;'\
                      'path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;path=a:2,b:_0;'\
                      'label= ;icon=image:18_junta/farm,large:2',
          },

          'J16' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:2;stripes=color:blue;label=L;upgrade=cost:80,terrain:river',
          },

          'J17' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'path=a:0,b:2;path=a:2,b:4;path=a:0,b:4;stripes=color:blue;label=L;',
          },
        }.freeze

        LOCATION_NAMES = {
          'L6' => 'Monterrey',
          'G7' => 'Valle Verde',
          'F10' => 'San Isidro',
          'A13' => 'Navidad',
          'D4' => 'Don Ramón',
          'K3' => 'San Miguel',
          'L12' => 'Puerto Viejo',
          'E11' => 'Laguna',
          'A2' => 'NEUTRAL',
        }.freeze

        # Rules summary 6.5: under Dictatorship the border cities become military tiles with fixed values.
        DICTATORSHIP_BORDER_TILES = {
          'A13' => 'offboard=revenue:80;path=a:4,b:_0;path=a:5,b:_0',
          'D4' => 'offboard=revenue:50;path=a:4,b:_0;path=a:5,b:_0',
          'L12' => 'offboard=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          'K3' => 'offboard=revenue:50;path=a:1,b:_0;path=a:2,b:_0;border=edge:0,type:impassable,color:black',
        }.freeze

        # A2 is a status tile that shows the Political Track; it is never upgraded.
        HEXES = {
          orange: {
            ['A2'] => '',
          },
          white: {
            %w[C9 D8 D14 H4 J4] => '', # open terrain
            %w[B14 C11 E7 F4 G13 I3 I9 L8] => 'icon=image:18_junta/militia,large:2',
            %w[C15 G1 G11 J2 K13] => 'town=revenue:0,style:hidden;label= ;icon=image:18_junta/farm;'\
                                     'upgrade=cost:25,terrain:swamp',
            %w[C13 E5 D10 E3 E13 F12 H2 I1 I5 I11 J12 K5 K9] => 'city=revenue:0', # cities
            %w[F2 H12] => 'town=revenue:0', # towns
            %w[F6 G5 G9 H10 L10 I7] => 'upgrade=cost:50,terrain:mountain', # mountains
            ['K11'] => 'upgrade=cost:50,terrain:mountain;icon=image:18_junta/militia,large:2',
            %w[B10 E9 G3 H6 J6 H8 J10] => 'town=revenue:0,style:hidden;label= ;icon=image:18_junta/farm,loc:15;'\
                                          'upgrade=cost:75,terrain:mountain|swamp',
            %w[D12 F8 K7] => 'town=revenue:0;upgrade=cost:50,terrain:mountain', # towns on mountains
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
            ['D6'] => 'city=revenue:20,slots:1;path=a:0,b:_0;path=a:4,b:_0',
          },
          red: {
            ['A13'] => 'offboard=revenue:yellow_40|brown_60;path=a:4,b:_0;path=a:5,b:_0;future_label=label:80,color:red',
            ['D4'] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;path=a:5,b:_0;future_label=label:50,color:red',
            ['L12'] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                       'future_label=label:40,color:red',
            ['K3'] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;future_label=label:50,color:red;'\
                      'border=edge:0,type:impassable,color:black',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
