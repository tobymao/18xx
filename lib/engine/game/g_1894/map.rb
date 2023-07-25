# frozen_string_literal: true

module Engine
  module Game
    module G1894
      module Map
        TILES = {
          '1' => 1,
          '7' => 4,
          '8' => 15,
          '9' => 12,
          '14' => 4,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '35' => 2,
          '36' => 2,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 1,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '56' => 1,
          '57' => 10,
          '58' => 3,
          '70' => 2,
          '118' => 2,
          '619' => 4,
          '624' => 1,
          '630' => 1,
          '631' => 1,
          '632' => 1,
          '633' => 1,
          'X1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30,loc:0.5,reservation:PLM;city=revenue:30;upgrade=cost:40,terrain:water;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;label=P',
          },
          'X2' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;upgrade=cost:40,terrain:water;path=a:0,b:_0;path=a:2,b:_0;label=B',
          },
          'X3' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;upgrade=cost:40,terrain:water;path=a:0,b:_0;path=a:1,b:_0;label=L',
          },
          'X4' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;upgrade=cost:60,terrain:water;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;label=P',
          },
          'X5' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:3.5;upgrade=cost:60,terrain:water;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=P',
          },
          'X6' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50,slots:2;upgrade=cost:60,terrain:water;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=B',
          },
          'X7' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:50;upgrade=cost:60,terrain:water;path=a:0,b:_0;path=a:1,b:_0;path=a:4,b:_0;label=L',
          },
          'X8' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;upgrade=cost:60,terrain:water;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;label=L',
          },
          'X9' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,loc:0.5;city=revenue:8 0,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;label=P',
          },
          'X10' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,loc:0.5;city=revenue:80,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=P',
          },
          'X9b' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:90,loc:0.5;city=revenue:90;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;label=P',
          },
          'X10b' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:90,loc:0.5;city=revenue:90;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=P',
          },
          'X11' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:70,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
          },
          'X12' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=L',
          },
          'X13' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                      'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
          'X14' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40,loc:3.5;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1',
          },
          'X15' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40,loc:2.5;path=a:0,b:_0;path=a:4,b:_0;path=a:2,b:_1;path=a:3,b:_1',
          },
          'X16' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40,loc:1.5;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,b:_1',
          },
          'X17' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_0;path=a:2,b:_1;path=a:4,b:_1',
          },
          'X18' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:4,b:_1',
          },
          'X19' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:3.5;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1',
          },
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Great Britain',
          'A10' => 'London',
          'A12' => 'London shipping',
          'B3' => 'Le Havre',
          'B9' => 'Calais',
          'B11' => 'Dunkerque',
          'B15' => 'Oostendee',
          'C14' => 'Brugge',
          'C18' => 'Netherlands',
          'E2' => 'Évreux',
          'D1' => 'Elbeuf',
          'D3' => 'Rouen',
          'D9' => 'Lens',
          'D11' => 'Lille',
          'D15' => 'Gent',
          'D17' => 'Antwerpen',
          'E6' => 'Amiens',
          'E10' => 'Arras',
          'E16' => 'Mechelen',
          'F1' => 'Dreux',
          'F15' => 'Bruxelles',
          'G4' => 'Versailles',
          'G6' => 'Paris',
          'G10' => 'Saint-Quentin',
          'G14' => 'Charleroi',
          'G18' => 'Hasselt',
          'H1' => 'Voves',
          'H3' => 'Chartres',
          'H9' => 'Soissons',
          'H17' => 'Liège',
          'I2' => 'Centre & Bourgogne',
          'I10' => 'Reims',
          'I18' => 'Luxembourg',
        }.freeze

        HEXES = {
          white: {
            %w[C4 C8 C10 D5 E8 E18 F3 F5 F9 F17 G2 H5 H7 I6 I8 I12] => '',
            %w[B1 E8 H11] => 'upgrade=cost:40,terrain:water',
            %w[B7 C2 E4 G8 I4] => 'upgrade=cost:60,terrain:water',
            %w[B3 B9 D3 D9 D15 D17 E2 E6 E10 E16 H9 H17] => 'city=revenue:0',
            %w[G10] => 'city=revenue:0;upgrade=cost:60,terrain:water',
            %w[F7 G16] => 'town=revenue:0;town=revenue:0',
            ['B11'] => 'city=revenue:0;border=edge:4,type:mountain',
            ['B13'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain',
            ['C6'] => 'town=revenue:0;town=revenue:10;path=a:5,b:_1',
            ['C12'] => 'upgrade=cost:40,terrain:water;border=edge:3,type:mountain;border=edge:4,type:mountain;'\
                       'border=edge:5,type:mountain',
            ['C14'] => 'city=revenue:0;border=edge:1,type:mountain',
            ['D7'] => 'town=revenue:0;town=revenue:10;path=a:2,b:_1',
            ['D11'] => 'city=revenue:0;label=L;border=edge:4,type:mountain',
            ['D13'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            ['E12'] => 'town=revenue:0;town=revenue:0;border=edge:3,type:mountain;border=edge:4,type:mountain;'\
                       'border=edge:5,type:mountain',
            ['E14'] => 'upgrade=cost:60,terrain:water;border=edge:1,type:mountain',
            ['F11'] => 'border=edge:4,type:mountain',
            ['F13'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            ['F15'] => 'city=revenue:0;label=B',
            ['G6'] => 'city=revenue:0;city=revenue:0;label=P',
            ['G12'] => 'town=revenue:0;town=revenue:0;border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['G14'] => 'city=revenue:0;border=edge:0,type:mountain;border=edge:1,type:mountain',
            ['H13'] => 'upgrade=cost:40,terrain:water;border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['H15'] => 'upgrade=cost:60,terrain:water;border=edge:0,type:mountain;border=edge:1,type:mountain',
            ['I14'] => 'border=edge:3,type:mountain',
          },
          yellow: {
            ['G4'] => 'city=revenue:20;path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['I10'] => 'city=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          gray: {
            ['A2'] => 'path=a:5,b:0;path=a:0,b:4;',
            ['A8'] => 'path=a:0,b:4;path=a:0,b:5;path=a:5,b:4;',
            ['B5'] => 'path=a:1,b:5;path=a:1,b:0;path=a:5,b:0',
            ['B15'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0',
            ['C16'] => 'path=a:0,b:1;path=a:4,b:5;path=a:5,b:0',
            ['D1'] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
            ['F1'] => 'town=revenue:20;path=a:3,b:_0;path=a:5,b:_0;path=a:3,b:4;path=a:4,b:5',
            ['G18'] => 'city=revenue:yellow_20|brown_30;path=a:0,b:1;path=a:1,b:2;path=a:0,b:_0;path=a:2,b:_0',
            ['H1'] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
            ['H3'] => 'city=revenue:yellow_20|brown_30;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['I16'] => 'path=a:1,b:4;path=a:1,b:2;path=a:3,b:4',
          },
          blue: {
            ['A10'] => 'town=revenue:yellow_30|brown_80;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0',
            ['A12'] => 'city=revenue:0;icon=image:1894/ferry;icon=image:1894/ferry;icon=image:1894/ferry',
          },
          red: {
            ['A4'] => 'offboard=revenue:50;icon=image:1894/coins;path=a:0,b:_0;path=a:1,b:_0',
            ['C18'] => 'offboard=revenue:30;icon=image:1894/plus_100;path=a:0,b:_0;path=a:1,b:_0',
            ['I2'] => 'offboard=revenue:40;icon=image:1894/coins;path=a:2,b:_0;path=a:4,b:_0',
            ['I18'] => 'offboard=revenue:0,hide:1;icon=image:1894/largest;icon=image:1894/coins;path=a:1,b:_0;path=a:2,b:_0',
          },
        }.freeze
      end
    end
  end
end
