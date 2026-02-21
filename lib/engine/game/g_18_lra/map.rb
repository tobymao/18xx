# frozen_string_literal: true

module Engine
  module Game
    module G18Lra
      module Map
        def game_tiles
          {
            '1' => 2,
            '3' => 2,
            '4' => 6,
            '5' => 2,
            '6' => 2,
            '7' => 3,
            '8' => 7,
            '9' => 7,
            '14' => 2,
            '15' => 2,
            '18' => 1,
            '19' => 1,
            '20' => 1,
            '23' => 2,
            '24' => 2,
            '25' => 1,
            '26' => 1,
            '27' => 1,
            '28' => 1,
            '29' => 1,
            '30' => 1,
            '31' => 1,
            '39' => 1,
            '40' => 1,
            '41' => 1,
            '42' => 1,
            '43' => 1,
            '44' => 1,
            '45' => 1,
            '46' => 1,
            '47' => 1,
            '55' => 2,
            '56' => 2,
            '57' => 2,
            '58' => 6,
            '69' => 2,
            '87' => 2,
            '88' => 2,
            '141' => 2,
            '142' => 2,
            '143' => 2,
            '144' => 1,
            '204' => 2,
            '619' => 2,
            '933' => 2,
            'L01' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0;label=CM;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L02' =>
            {
              'count' => 3,
              'color' => 'yellow',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;label=CM;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L03' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0;label=CM;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L04' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30,loc:4.5;upgrade=cost:30,terrain:water;path=a:5,b:_0;'\
                        'path=a:3,b:_0;label=D;partition=a:0,b:3,type:water',
            },
            'L05' =>
            {
              'count' => 3,
              'color' => 'yellow',
              'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:3,b:_0;label=DU;'\
                        'icon=image:../logos/18_rhl/S,sticky:0;border=edge:2,type:impassable,color:blue',
            },
            'L06' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:0,loc:1;path=a:0,b:_0;path=a:3,b:_0;label=MG',
            },
            'L07' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:0,loc:4;path=a:0,b:_0;path=a:2,b:_0;label=MG',
            },
            'L08' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0;label=MO;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L09' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:20;path=a:0,b:_0;path=a:5,b:_0;label=MO;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L10' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L11' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L12' =>
            {
              'count' => 2,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L13' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                        'label=CM;icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L14' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20;city=revenue:20;label=GEL;'\
                        'path=a:0,b:_0;path=a:_0,b:3;path=a:5,b:_1;path=a:_1,b:2',
            },
            'L15' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;label=D;upgrade=cost:30,terrain:river;'\
                        'path=a:0,b:_0,track:narrow;path=a:3,b:_0;path=a:5,b:_0;icon=image:18_rhl/trajekt,sticky:0;'\
                        'border=edge:1,type:impassable,color:blue;border=edge:2,type:impassable,color:blue',
            },
            'L16' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2;label=DU;border=edge:1,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L17' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40,slots:2,loc:5.5;city=revenue:30;label=KR;'\
                        'path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;'\
                        'icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L18' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40,loc:5;label=MG;'\
                        'path=a:5,b:_1;path=a:_1,b:1;path=a:0,b:_0;path=a:_0,b:3',
            },
            'L19' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40,loc:5;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:5;',
            },
            'L20' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40,loc:1;label=MG;'\
                        'path=a:5,b:_1;path=a:_1,b:1;path=a:0,b:_0;path=a:_0,b:4',
            },
            'L21' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:2;path=a:4,b:_1;path=a:_1,b:5',
            },
            'L22' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:5',
            },
            'L23' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:3;path=a:4,b:_1;path=a:_1,b:5',
            },
            'L24' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:40;city=revenue:40;label=MG;'\
                        'path=a:0,b:_0;path=a:_0,b:2;path=a:3,b:_1;path=a:_1,b:4',
            },
            'L25' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;label=MO;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L26' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;label=MO;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L27' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:30,slots:2;label=NE;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;border=edge:5,type:impassable,color:blue',
            },
            'L28' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:10,slots:2;label=OY;path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0;'\
                        'border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
            },
            'L29' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20;label=RH;upgrade=cost:30,terrain:river;'\
                        'path=a:3,b:_0,track:narrow;path=a:0,b:_0;path=a:1,b:_0;'\
                        'border=edge:4,type:impassable,color:blue;border=edge:5,type:impassable,color:blue;'\
                        'icon=image:18_rhl/trajekt,sticky:0;icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L30' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20,slots:2;label=RU;upgrade=cost:30,terrain:river;'\
                        'path=a:0,b:_0,track:narrow;path=a:3,b:_0;path=a:5,b:_0;'\
                        'border=edge:1,type:impassable,color:blue',
            },
            'L31' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' => 'city=revenue:20,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:5,b:_0;label=UE;'\
                        'border=edge:3,type:impassable,color:blue',
            },
            'L32' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'town=revenue:20;label=CM;icon=image:../logos/18_rhl/K,sticky:0;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
            'L33' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'town=revenue:20;label=CM;icon=image:../logos/18_rhl/K,sticky:0;'\
                        'path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            },
            'L34' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:3;label=D;path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0;'\
                        'border=edge:1,type:impassable,color:blue;border=edge:2,type:impassable,color:blue;',
            },
            'L35' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:60,slots:3;label=DU;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                        'border=edge:2,type:impassable,color:blue;icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L36' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;label=KR;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L37' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:50,slots:3;label=MG;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
            'L38' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:40,slots:3;label=MO;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/K,sticky:0',
            },
            'L39' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:40,slots:2;label=NE;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
            'L40' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:20,slots:2;label=OY;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'border=edge:4,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',
            },
            'L41' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:30,slots:2;label=RH;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                        'border=edge:5,type:impassable,color:blue;icon=image:../logos/18_rhl/S,sticky:0',
            },
            'L42' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:30,slots:3;label=RU;border=edge:2,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            },
            'L43' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' => 'city=revenue:30,slots:3;label=UE;border=edge:4,type:impassable,color:blue;'\
                        'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
            },
          }
        end

        LOCATION_NAMES_18LRA = {
          'A1' => 'Kevelar',
          'A5' => 'Wesel',
          'A7' => 'Issum',
          'A11' => 'Kleve',
          'A15' => 'Oberhausen',
          'B2' => 'Walbeck',
          'B4' => 'Geldern',
          'B8' => 'Kamp-Lintfort',
          'B12' => 'Orsoy',
          'B14' => 'Ruhrort',
          'B16' => 'Essen',
          'C3' => 'Straelen',
          'C9' => 'Neukirchen-Vluyn',
          'C11' => 'Moers',
          'C13' => 'Homberg',
          'C15' => 'Duisburg',
          'D4' => 'Wachtendonk',
          'D6' => 'Aldekerk',
          'D12' => 'Trompet Rumeln',
          'D14' => 'Rheinhausen',
          'E1' => 'Venio',
          'E7' => 'Kempen',
          'E9' => 'Niep Hüls',
          'E13' => 'Uerdingen',
          'E15' => 'Ratingen',
          'F2' => 'Kaldenkirchen',
          'F6' => 'Grefrath Süchteln',
          'F10' => 'Krefeld',
          'F12' => 'Linn Oppum',
          'G3' => 'Brüggen',
          'G7' => 'Viersen',
          'G9' => 'Willich',
          'G13' => 'Osterath',
          'G15' => 'Düsseldorf',
          'H2' => 'Antwerpen',
          'H8' => 'Münchengladbach',
          'H14' => 'Neuss',
          'H16' => 'Elberfeld',
          'I3' => 'Dalhem',
          'I7' => 'Rheydt',
          'I9' => 'Geneicken',
          'I13' => 'Dormagen',
          'J2' => 'Herzogenrath',
          'J4' => 'Erkelenz',
          'J6' => 'Wickrath',
          'J8' => 'Odenkirchen',
          'J10' => 'Grevenbroich',
          'K3' => 'Aachen',
          'K7' => 'Jülich',
          'K9' => 'Düren',
          'K11' => 'Köln',
          'K15' => 'Köln',
        }.freeze

        def location_name(coord)
          self.class::LOCATION_NAMES_18LRA[coord]
        end

        def base_map
          {
            red: {
              ['A5'] => 'city=revenue:yellow_20|brown_40;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1',
              ['A7'] => 'offboard=revenue:yellow_10|brown_20;path=a:5,b:_0',
              ['A11'] => 'offboard=revenue:yellow_10|brown_30;path=a:0,b:_0,terminal:1;path=a:5,b:_0,terminal:1;'\
                         'border=edge:4,type:impassable,color:blue',
              ['A13'] => 'offboard=revenue:yellow_20|brown_50,groups:Oberhausen;icon=image:../logos/18_rhl/K;'\
                         'border=edge:4;border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue',
              ['A15'] => 'offboard=revenue:yellow_20|brown_50,hide:1,groups:Oberhausen;icon=image:18_rhl/ERh;'\
                         'path=a:0,b:_0,terminal:1;border=edge:1',
              ['B16'] => 'city=revenue:yellow_20|brown_50;path=a:0,b:_0,terminal:1;'\
                         'icon=image:../logos/18_rhl/S;icon=image:18_rhl/ERh',
              ['H2'] => 'offboard=revenue:yellow_10|brown_30,group:Antwerpen,hide:1;border=edge:0;icon=image:18_rhl/ERh',
              ['H16'] => 'city=revenue:yellow_20|brown_40;path=a:2,b:_0,terminal:1;border=edge:1,type:impassable,color:blue',
              ['I1'] => 'offboard=revenue:yellow_10|brown_30,group:Antwerpen;path=a:4,b:_0,terminal:1;border=edge:3',
              ['K1'] => 'offboard=revenue:yellow_20|brown_40,group:Aachen;border=edge:4;icon=image:../logos/18_rhl/K',
              ['K3'] => 'city=revenue:yellow_20|brown_40,group:Aachen,hide:1;'\
                        'border=edge:1;path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
              ['K5'] => 'offboard=revenue:yellow_10|brown_20,group:Julich;border=edge:4;path=a:2,b:_0,terminal:1',
              ['K7'] => 'offboard=revenue:yellow_10|brown_20,group:Julich,hide:1;border=edge:1;path=a:3,b:_0,terminal:1',
              ['K9'] => 'offboard=revenue:yellow_10|brown_20;path=a:3,b:_0,terminal:1',
              ['K11'] => 'city=revenue:yellow_30|brown_60;path=a:2,b:_0,terminal:1',
              ['K15'] => 'city=revenue:yellow_30|brown_60;path=a:2,b:_0,terminal:1;border=edge:4,type:impassable,color:blue',
            },
            gray: {
              %w[A9 C1 G1 K13] => '',
              ['A1'] => 'city=revenue:yellow_10|brown_20,groups:Kevelar,hide:1;border=edge:4;path=a:5,b:_0,terminal:1',
              ['A3'] => 'offboard=revenue:yellow_10|brown_20,group:Kevelar;border=edge:1;path=a:5,b:_0',
              ['C3'] => 'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
              ['D2'] => 'offboard=revenue:yellow_20|brown_40,slots:2,loc:0,groups:Venio;path=a:0,b:3;border=edge:0',
              ['D6'] => 'town=revenue:10;path=a:2,b:_0;path=a:5,b:_0',
              %w[D16 I9] => 'path=a:0,b:2',
              ['E1'] => 'city=revenue:yellow_20|brown_40,slots:2,loc:3,groups:Venio,hide:1;'\
                        'path=a:3,b:_0;path=a:5,b:_0;border=edge:3',
              ['F16'] => 'path=a:0,b:2;border=edge:1,type:impassable,color:blue',
              ['I15'] => 'border=edge:0,type:impassable,color:blue;'\
                         'border=edge:1,type:impassable,color:blue;border=edge:2,type:impassable,color:blue',
              ['J2'] => 'town=revenue:yellow_20|brown_50,loc:4;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;'\
                        'icon=image:../logos/18_rhl/K',
              ['J16'] => 'border=edge:0,type:impassable,color:blue;border=edge:1,type:impassable,color:blue',
            },
            white: {
              %w[B10 C5 C7 D8 D10 E3 E5 E11 F4 F8 F14 G5 G11 H4 H6 H10 H12 I5 I11 J12 J14] => '',
              %w[E7 G7 J10] => 'city=revenue:0',
              %w[D12 E9 F6 F12] => 'town=revenue:0;town=revenue:0',
              %w[B2 D4 F2 G3 G9 G13 J4 J8] => 'town=revenue:0',
              ['B6'] => 'icon=image:1893/green_hex',
              %w[B8 C9] => 'town=revenue:0;label=CM;icon=image:../logos/18_rhl/K',
              ['C11'] => 'city=revenue:0;icon=image:../logos/18_rhl/K;icon=image:1893/green_hex',
              ['C13'] => 'town=revenue:0;border=edge:4,type:impassable,color:blue;icon=image:../logos/18_rhl/K;stub=edge:3',
              ['C15'] => 'city=revenue:0;border=edge:1,type:impassable,color:blue;label=DU;upgrade=cost:30,terrain:water;'\
                         'icon=image:../logos/18_rhl/S',
              ['E15'] => 'town=revenue:0;border=edge:0,type:impassable,color:blue;upgrade=cost:30,terrain:water;'\
                         'border=edge:1,type:impassable,color:blue;border=edge:2,type:impassable,color:blue',
              ['F14'] => 'border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['G15'] => 'city=revenue:0;border=edge:0,type:impassable,color:blue;label=D;upgrade=cost:30,terrain:water;'\
                         'border=edge:1,type:impassable,color:blue;border=edge:2,type:impassable,color:blue',
              %w[H8 I7] => 'city=revenue:0;city=revenue:0;label=MG;',
              ['I13'] => 'town=revenue:0;border=edge:4,type:impassable,color:blue',
              ['J6'] => 'town=revenue:0;stub=edge:3',
              ['J14'] => 'border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
            },
            yellow: {
              ['B4'] => 'city=revenue:10;city=revenue:10;path=a:0,b:_0;path=a:3,b:_1;label=GE',
              ['B12'] => 'town=revenue:10,loc:2;city=revenue:0,loc:3.5;path=a:5,b:_0;path=a:2,b:_0;label=OY;'\
                         'border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue',
              ['B14'] => 'city=revenue:0,loc:1;city=revenue:20,loc:4;path=a:5,b:_1;path=a:3,b:_1;label=RU;'\
                         'border=edge:1,type:impassable,color:blue;stub=edge:0;upgrade=cost:30,terrain:water',
              ['D14'] => 'town=revenue:0;label=RH;stub=edge:3;icon=image:../logos/18_rhl/S;upgrade=cost:30,terrain:water;'\
                         'border=edge:4,type:impassable,color:blue;border=edge:5,type:impassable,color:blue',
              ['E13'] => 'city=revenue:20;city=revenue:0,loc:3.5;path=a:0,b:_0;label=UE;'\
                         'border=edge:4,type:impassable,color:blue;stub=edge:1',
              ['F10'] => 'city=revenue:0;city=revenue:30;path=a:5,b:_1;path=a:4,b:_1;label=KR;icon=image:../logos/18_rhl/S',
              ['I3'] => 'city=revenue:10;path=a:1,b:_0;path=a:4,b:_0',
              ['H14'] => 'city=revenue:20;city=revenue:0,loc:4.5;path=a:0,b:_0;path=a:2,b:_0;label=NE;'\
                         'border=edge:3,type:impassable,color:blue;border=edge:4,type:impassable,color:blue;'\
                         'border=edge:5,type:impassable,color:blue',
            },
          }
        end

        def show_map_legend?
          true
        end

        def map_legends
          ['bonus_legend']
        end

        def bonus_legend(_font_color, *_extra_colors)
          [
            # table-wide props
            {
              style: {
                margin: '0.5rem 0 0.5rem 0',
                border: '1px solid',
                borderCollapse: 'collapse',
              },
            },
            # header
            [
              { text: 'Bonus', props: { style: { border: '1px solid' } } },
              { text: 'Run', props: { style: { border: '1px solid' } } },
              { text: 'Icons', props: { style: { border: '1px solid' } } },
              { text: 'M', props: { style: { border: '1px solid' } } },
            ],
            # body
            [
              { text: 'Eisener Rhein (Iron Rhine)', props: { style: { border: '1px solid' } } },
              { text: 'A15/B16 - Antwerpen', props: { style: { textAlign: 'center', border: '1px solid' } } },
              { text: 'ERh x 2', props: { style: { textAlign: 'center', border: '1px solid' } } },
              { text: '80', props: { style: { textAlign: 'right', border: '1px solid' } } },
            ],
          ]
        end
      end
    end
  end
end
