# frozen_string_literal: true

module Engine
  module Game
    module G1882
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '3' => 1,
          '4' => 1,
          '7' => 5,
          '8' => 10,
          '9' => 10,
          '14' => 3,
          '15' => 2,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '26' => 1,
          '27' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 4,
          '58' => 1,
          '59' => 1,
          '63' => 3,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '69' => 1,
          'R1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:60;city=revenue:60;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=R',
          },
          'R2' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:70,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=R',
          },
        }.freeze

        LOCATION_NAMES = {
          'I1' => 'Western Canada (HB +100)',
          'B2' => 'Northern Alberta (HB +100)',
          'L2' => 'Lethbridge',
          'C3' => 'Lloydminster',
          'G3' => 'Kindersley',
          'K3' => 'Medicine Hat',
          'M3' => 'Elkwater',
          'D4' => 'Maidstone',
          'F4' => 'Wilkie',
          'E5' => 'North Battleford & Battleford',
          'I5' => 'Swift Current',
          'D6' => 'Spiritwood',
          'N6' => 'Shaunavon',
          'G7' => 'Saskatoon',
          'D8' => 'Prince Albert',
          'F8' => 'Rosthern & Melfort',
          'J8' => 'Moose Jaw',
          'L8' => 'Assiniboia',
          'C9' => 'Candle Lake',
          'G9' => 'Humboldt',
          'K9' => 'Rouleau & Mossbank',
          'J10' => "Pile o' Bones & Lumsden",
          'A11' => 'Sandy Bay',
          'C11' => 'Flin Flon',
          'G11' => 'Wadena',
          'I11' => "Melville & Fort Qu'Appelle",
          'M11' => 'Wayburn & Estevan',
          'O11' => 'USA',
          'B12' => 'Hudson Bay',
          'J12' => 'Moosomin',
          'L12' => 'Carlyle',
          'N12' => 'Oxbow',
          'I13' => 'Eastern Canada',
          'K13' => 'Virden',
        }.freeze

        HEXES = {
          red: {
            ['I1'] => 'offboard=revenue:yellow_40|brown_80;path=a:4,b:_0;path=a:5,b:_0',
            ['B2'] =>
                   'offboard=revenue:yellow_30|brown_60;border=edge:0,type:water,cost:40;path=a:0,b:_0;path=a:5,b:_0',
            ['O11'] => 'offboard=revenue:yellow_30|brown_30;path=a:3,b:_0',
            ['B12'] =>
                   'offboard=revenue:yellow_40|brown_50;border=edge:0,type:water,cost:60;path=a:0,b:_0;path=a:1,b:_0',
            ['I13'] => 'offboard=revenue:yellow_30|brown_40;path=a:1,b:_0;path=a:2,b:_0',
          },
          white: {
            %w[F2 H2 K5 M5 L6 M7 M9 B10 L10 H12] => '',
            ['K11'] => 'border=edge:3,type:water,cost:40',
            ['J2'] => 'border=edge:4,type:water,cost:20',
            ['L4'] => 'border=edge:2,type:water,cost:40',
            ['B4'] => 'icon=image:1882/NWR,sticky:1',
            %w[G3 L8 G11 J12] => 'city=revenue:0',
            ['C3'] =>
            'city=revenue:0;border=edge:1,type:water,cost:20;border=edge:0,type:water,cost:40;'\
            'icon=image:1882/NWR,sticky:1',
            ['K3'] =>
            'city=revenue:0;border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:40;'\
            'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40;'\
            'border=edge:5,type:water,cost:40',
            ['D4'] =>
            'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40;'\
            'border=edge:5,type:water,cost:20;icon=image:1882/NWR,sticky:1',
            ['D6'] =>
            'city=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40;'\
            'icon=image:1882/NWR,sticky:1',
            ['G7'] =>
            'city=revenue:0;border=edge:3,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['J8'] => 'city=revenue:0;border=edge:2,type:water,cost:40',
            ['G9'] =>
            'city=revenue:0;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:40',
            ['C11'] =>
            'city=revenue:0;border=edge:0,type:water,cost:60;border=edge:5,type:water,cost:60',
            ['I5'] =>
            'city=revenue:0;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:40;'\
            'border=edge:4,type:water,cost:40',
            ['M3'] =>
            'town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:3,type:water,cost:20',
            ['D2'] => 'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:20',
            ['F6'] =>
            'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:20;icon=image:1882/NWR,sticky:1',
            ['E3'] =>
            'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            ['J6'] => 'border=edge:3,type:water,cost:40;border=edge:4,type:water,cost:40',
            ['I3'] =>
            'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:20;border=edge:5,type:water,cost:40',
            ['E7'] =>
            'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:20;'\
            'border=edge:5,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            %w[J4 H8] =>
            'border=edge:1,type:water,cost:40;border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40',
            ['C5'] => 'border=edge:0,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            ['G5'] => 'border=edge:0,type:water,cost:40',
            ['H4'] => 'border=edge:0,type:water,cost:40;border=edge:5,type:water,cost:20',
            ['H6'] => 'border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
            ['I7'] =>
            'border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:40;'\
            'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['K7'] => 'border=edge:3,type:water,cost:20',
            ['E9'] =>
            'border=edge:0,type:water,cost:40;border=edge:3,type:water,cost:20;'\
            'border=edge:4,type:water,cost:40;border=edge:5,type:water,cost:40',
            ['I9'] => 'border=edge:5,type:water,cost:60',
            ['D10'] =>
            'border=edge:0,type:water,cost:60;border=edge:1,type:water,cost:40;border=edge:5,type:water,cost:40',
            %w[F10 E11] =>
            'border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:60',
            ['H10'] => 'border=edge:0,type:water,cost:20',
            ['D12'] =>
            'border=edge:3,type:water,cost:60;border=edge:2,type:water,cost:60',
            ['L12'] => 'town=revenue:0',
            ['F4'] => 'town=revenue:0;border=edge:3,type:water,cost:40',
            ['K9'] => 'town=revenue:0;town=revenue:0',
            ['I11'] =>
            'town=revenue:0;town=revenue:0;border=edge:0,type:water,cost:40;border=edge:1,type:water,cost:40',
            ['F8'] =>
            'town=revenue:0;town=revenue:0;border=edge:0,type:water,cost:40;'\
            'border=edge:2,type:water,cost:40;border=edge:3,type:water,cost:40;'\
            'border=edge:5,type:water,cost:20',
          },
          gray: {
            ['L2'] =>
                     'city=revenue:40;path=a:4,b:_0;path=a:_0,b:5;border=edge:4,type:water,cost:40',
            ['N6'] => 'city=revenue:30;path=a:2,b:_0;path=a:_0,b:4',
            ['C7'] => 'path=a:0,b:1;border=edge:5',
            ['D8'] =>
            'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;border=edge:0,type:water,cost:40;border=edge:2;border=edge:4',
            ['N8'] => 'path=a:3,b:4',
            ['C9'] =>
            'town=revenue:10;path=a:0,b:_0;path=a:_0,b:4;border=edge:0,type:water,cost:20;border=edge:1',
            ['N10'] => 'path=a:2,b:4',
            ['A11'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:1',
            ['N12'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:3',
            ['K13'] => 'city=revenue:20;path=a:2,b:_0',
          },
          yellow: {
            ['M11'] => 'city=revenue:0;city=revenue:0;label=OO',
            ['E5'] =>
            'city=revenue:0;city=revenue:0;label=OO;border=edge:2,type:water,cost:20;'\
            'border=edge:3,type:water,cost:40;'\
            'border=edge:4,type:water,cost:40;icon=image:1882/NWR,sticky:1',
            ['J10'] =>
            'city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:4,b:_1;label=R;'\
            'border=edge:2,type:water,cost:60;border=edge:3,type:water,cost:20;'\
            'border=edge:4,type:water,cost:40',
            ['F12'] => 'path=a:1,b:3',
          },
          blue: {
            ['B6'] =>
                        'offboard=revenue:yellow_20|brown_30,visit_cost:0,route:optional;'\
                        'path=a:0,b:_0;path=a:1,b:_0;icon=image:1882/fish',
          },
        }.freeze

        LAYOUT = :flat

        AXES = { x: :number, y: :letter }.freeze
      end
    end
  end
end
