# frozen_string_literal: true

module Engine
  module Game
    module G18NY
      module Map
        TILES = {
        }.freeze

        LOCATION_NAMES = {
          'B12' => 'Watertown',
          'C11' => 'Oswego',
          'C23' => 'Rutland',
          'D2' => 'Niagara Falls',
          'D4' => 'Lockport',
          'D8' => 'Rochester',
          'D12' => 'Syracuse',
          'D14' => 'Rome',
          'D18' => 'Amsterdam',
          'D20' => 'Saratoga Springs',
          'E3' => 'Buffalo',
          'E5' => 'Batavia',
          'E9' => 'Geneva',
          'E11' => 'Auburn',
          'E15' => 'Utica',
          'E19' => 'Schenectady',
          'E21' => 'Troy',
          'F10' => 'Ithaca',
          'F12' => 'Cortland',
          'F20' => 'Albany',
          'G9' => 'Elmira',
          'G13' => 'Binghamton',
          'G19' => 'Kingston',
          'G21' => 'Hudson',
          'H14' => 'Carbondale',
          'H20' => 'Poughkeepsie',
          'I19' => 'Newburgh',
          'I23' => 'Bridgeport',
          'J18' => 'Newark',
          'J20' => 'New York',
          'J22' => 'Hempstead',
          'K19' => 'Brooklyn',
        }.freeze

        HEXES = {
          white: {
            %w[B14, F4, F24, G7, G11, H24, K21] => '',
            %w[B16, B24, C15, C19, D24, E23, F2, F14, F16, F18, F22, G3, G5, G15, G23, H16, H22, I15, I17, J16] => 
              'upgrade=cost:60,terrain:mountain',
            %w[B18, G17] => 'upgrade=cost:120,terrain:mountain',
            %w[B20] => 'border=edge:4,type:water,cost:60;border=edge:5,type:impassable;upgrade=cost:60,terrain:mountain',
            %w[B22] => 'border=edge:1,type:water,cost:60',
            %w[C13] => 'border=edge:0,type:impassable',
            %w[J24] => 'border=edge:2,type:impassable',
            %w[C17] => 'border=edge:5,type:impassable;upgrade=cost:60,terrain:mountain',
            %w[C21] => 'border=edge:0,type:water,cost:40;border=edge:2,type:impassable',
            %w[D6] => 'border=edge:4,type:water,cost:60;border=edge:5,type:water,cost:60;icon=image:18_ny/canal,sticky:1',
            %w[D10, E13] => 'icon=image:18_ny/canal,sticky:1',
            %w[D16] => 'border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:60',
            %w[D22] => 'border=edge:1,type:water,cost:60',
            %w[E7] => 'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:60;border=edge:2,type:water,cost:60',
            %w[E17] => 'border=edge:2,type:water,cost:60;border=edge:3,type:water,cost:60;icon=image:18_ny/canal,sticky:1',
            %w[F6] => 'border=edge:3,type:water,cost:40;upgrade=cost:60,terrain:mountain',
            %w[F8] => 'border=edge:4,type:impassable;upgrade=cost:60,terrain:mountain',
            %w[H18] => 'border=edge:4,type:water,cost:80',
            %w[I21] => 'border=edge:1,type:water,cost:80',
            %w[B12] => 'town=revenue:0;icon=image:18_ny/connection_bonus',
            %w[C11] => 'town=revenue:0;icon=image:18_ny/connection_bonus',
            %w[C23] => 'town=revenue:0;icon=image:18_ny/connection_bonus',
            %w[G9] => 'town=revenue:0;icon=image:18_ny/connection_bonus',
            %w[G13] => 'town=revenue:0;icon=image:18_ny/connection_bonus',
            %w[D18] => 'town=revenue:0;border=edge:0,type:water,cost:60;border=edge:2,type:impassable;icon=image:18_ny/connection_bonus',
            %w[D20] => 'town=revenue:0;border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:60;border=edge:5,type:water,cost:60;icon=image:18_ny/connection_bonus',
            %w[E9] => 'town=revenue:0;border=edge:4,type:impassable;icon=image:18_ny/connection_bonus',
            %w[F10] => 'town=revenue:0;upgrade=cost:60,terrain:mountain;border=edge:1,type:impassable;border=edge:3,type:impassable;icon=image:18_ny/connection_bonus',
            %w[F12] => 'town=revenue:0;upgrade=cost:60,terrain:mountain;icon=image:18_ny/connection_bonus',
            %w[G19] => 'town=revenue:0;border=edge:4,type:water,cost:80;border=edge:5,type:water,cost:80;icon=image:18_ny/connection_bonus',
            %w[G21] => 'town=revenue:0;border=edge:1,type:water,cost:80;icon=image:18_ny/connection_bonus',
            %w[I19] => 'town=revenue:0;border=edge:3,type:water,cost:80;border=edge:4,type:water,cost:80;icon=image:18_ny/connection_bonus',
            %w[I23] => 'town=revenue:0;border=edge:0,type:impassable;border=edge:5,type:impassable;icon=image:18_ny/connection_bonus',
            %w[J22] => 'town=revenue:0;border=edge:2,type:impassable;border=edge:3,type:impassable;icon=image:18_ny/connection_bonus',
            %w[D2] => 'city=revenue:0;upgrade=cost:80,terrain:water',
            %w[D4] => 'city=revenue:0;icon=image:18_ny/canal,sticky:1',
            %w[D14] => 'city=revenue:0;icon=image:18_ny/canal,sticky:1',
            %w[D8] => 'city=revenue:0;border=edge:1,type:water,cost:60;icon=image:18_ny/canal,sticky:1',
            %w[D12] => 'city=revenue:0;border=edge:3,type:impassable;icon=image:18_ny/canal,sticky:1',
            %w[E5] => 'city=revenue:0;border=edge:4,type:water,cost:60',
            %w[E11] => 'city=revenue:0;border=edge:0,type:impassable;border=edge:1,type:impassable',
            %w[E15] => 'city=revenue:0;border=edge:3,type:water,cost:40;icon=image:18_ny/canal,sticky:1',
            %w[E19] => 'city=revenue:0;border=edge:4,type:water,cost:80;upgrade=cost:60,terrain:water;icon=image:18_ny/canal,sticky:1',
            %w[E21] => 'city=revenue:0;border=edge:1,type:water,cost:80;border=edge:2,type:water,cost:60',
            %w[H14] => 'city=revenue:0',
            %w[J18] => 'city=revenue:0',
            %w[H20] => 'city=revenue:0;border=edge:0,type:water,cost:80;border=edge:1,type:water,cost:80;border=edge:2,type:water,cost:80',
            %w[K19] => 'city=revenue:0;upgrade=cost:80,terrain:water',
          },
          yellow: {
            %w[E3] => 'city=revenue:20,slots:2;border=edge:1,type:water,cost:80;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            %w[F20] => 'label=A;city=revenue:40;upgrade=cost:80,terrain:water;path=a:0,b:_0;path=a:2,b:_0',
            %w[J20] => 'label=N;city=revenue:50;upgrade=cost:80,terrain:water;path=a:3,b:_0',
          },
          red: {
            %w[A11, A13, A15, A17, A19, A21, A23, A25] => '',
            %w[B26, C25, D26, E25, F26, G25, H26, I25, J26] => '',
            %w[D0, E1, F0, G1] => '',
            %w[H2, H4, H6, H8, H10, H12] => '',
            %w[I13, J14, K15, K17] => '',
          },
          blue: {
            %w[B10, C1, C3, C5, C7, C9, K23, K25] => '',
          }
        }.freeze

        LAYOUT = :pointy

        AXES = { x: :number, y: :letter }.freeze
      end
    end
  end
end
