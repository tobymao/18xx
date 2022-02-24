# frozen_string_literal: true

module Engine
  module Game
    module G1894
      module Map
        TILES = {
          '1' => 1,
          '2' => 1,
          '7' => 4,
          '8' => 13,
          '9' => 13,
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
          '35' => 1,
          '36' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '55' => 1,
          '56' => 1,
          '57' => 6,
          '58' => 3,
          '69' => 1,
          '70' => 1,
          '118' => 1,
          '619' => 4,
          '624' => 1,
          'X1' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30,loc:0.5,reservation:PLM;city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;label=P',
          },
          'X2' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:30;path=a:0,b:_0;path=a:2,b:_0;label=B',
          },
          'X3' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:10;path=a:0,b:_0;path=a:3,b:_0;label=A',
          },
          'X4' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,loc:0.5;city=revenue:30,loc:2.5;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;label=P',
          },
          'X5' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,loc:0.5;city=revenue:30,loc:3.5;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=P',
          },
          'X6' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:30,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=B',
          },
          'X7' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,loc:0.5;city=revenue:80,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;path=a:3,b:_1;label=P',
          },
          'X8' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:80,loc:0.5;city=revenue:80,slots:2;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1;label=P',
          },
          'X9' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=B',
          },
          'X10' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40,loc:3.5;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1',
          },
          'X11' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40,loc:2.5;path=a:0,b:_0;path=a:4,b:_0;path=a:2,b:_1;path=a:3,b:_1',
          },
          'X12' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40,loc:1.5;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:2,b:_1',
          },
          'X13' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_0;path=a:2,b:_1;path=a:4,b:_1',
          },
          'X14' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:3,b:_0;path=a:1,b:_1;path=a:4,b:_1',
          },
          'X15' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:3.5;'\
                      'path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_1;path=a:4,b:_1',
          },
        }.freeze

        LOCATION_NAMES = {
          'A4' => 'Ireland',
          'A10' => 'England',
          'B3' => 'Le Havre',
          'B9' => 'Calais',
          'B11' => 'Dunkerque',
          'C16' => 'Netherlands',
          'D1' => 'Évreux',
          'D3' => 'Rouen',
          'D11' => 'Lille',
          'D15' => 'Gent',
          'D17' => 'Antwerpen',
          'E6' => 'Amiens',
          'E10' => 'Arras',
          'E16' => 'Mechelen',
          'F15' => 'Bruxelles',
          'G2' => 'Versailles',
          'G4' => 'Paris',
          'G10' => 'Saint-Quentin',
          'G14' => 'Charleroi',
          'H17' => 'Liège',
          'I2' => 'Le Sud',
          'I8' => 'Reims',
          'I18' => 'Luxembourg',
        }.freeze

        HEXES = {
          white: {
            %w[C4 D7 D9 E2 E8 E18 F1 F3 F7 F9 F17 G8 H1 H3 H11 I4 I10 I12] => '',
            %w[B1 B7 C2 C8 C10 D5 E4 G6 H5 H9] => 'upgrade=cost:60,terrain:water',
            %w[B3 B9 B11 D3 D15 E6 E10 E16 G10 H17] => 'city=revenue:0',
            ['B13'] => 'border=edge:5,type:mountain',
            ['C12'] => 'border=edge:4,type:mountain;border=edge:5,type:mountain',
            ['C14'] => 'upgrade=cost:60,terrain:water;border=edge:1,type:mountain;border=edge:2,type:mountain',
            ['D11'] => 'city=revenue:0;border=edge:4,type:mountain',
            ['D13'] => 'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            ['E12'] => 'upgrade=cost:60,terrain:water;'\
                       'border=edge:3,type:mountain;border=edge:4,type:mountain;border=edge:5,type:mountain',
            ['E14'] => 'border=edge:1,type:mountain',
            ['F11'] => 'border=edge:4,type:mountain',
            ['F13'] => 'upgrade=cost:60,terrain:water;'\
                       'border=edge:0,type:mountain;border=edge:1,type:mountain;border=edge:2,type:mountain',
            ['G4'] => 'city=revenue:0;city=revenue:0;label=P',
            ['G12'] => 'border=edge:3,type:mountain;border=edge:4,type:mountain',
            ['G14'] => 'city=revenue:0;border=edge:0,type:mountain;border=edge:1,type:mountain',
            ['H15'] => 'upgrade=cost:60,terrain:water;border=edge:0,type:mountain;border=edge:1,type:mountain',
            ['I14'] => 'border=edge:3,type:mountain',
            ['F15'] => 'city=revenue:0;label=B',
            %w[C6 F5 G16 H7] => 'town=revenue:0;town=revenue:0',
            %w[H13] => 'town=revenue:0;town=revenue:0;border=edge:3,type:mountain;border=edge:4,type:mountain',
          },
          yellow: {
            ['D17'] => 'city=revenue:20;path=a:0,b:_0;path=a:1,b:_0',
            ['G2'] => 'city=revenue:20;path=a:2,b:_0;path=a:4,b:_0',
            ['I6'] => 'path=a:1,b:3;stub=edge:2',
            ['I8'] => 'city=revenue:10;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          gray: {
            ['A8'] => 'path=a:0,b:4,b_lane:2.1;path=a:5,b:4,b_lane:2.0;'\
                      'icon=image:1894/ferry;icon=image:1894/ferry;icon=image:1894/ferry;icon=image:1894/ferry',
            ['A10'] => 'city=revenue:yellow_30|brown_70;path=a:0,b:_0;path=a:1,b:_0,lanes:2;path=a:5,b:_0;',
            ['B5'] => 'path=a:1,b:5;',
            ['D1'] => 'town=revenue:20;path=a:3,b:_0;path=a:5,b:_0',
            ['G18'] => 'path=a:0,b:2;',
            ['I16'] => 'path=a:1,b:4;path=a:1,b:2;',
          },
          red: {
            ['A2'] => 'offboard=revenue:yellow_50|brown_60,hide:1,groups:Ireland;path=a:0,b:_0;border=edge:4',
            ['A4'] => 'offboard=revenue:yellow_50|brown_60,groups:Ireland;path=a:0,b:_0;border=edge:1',
            ['C16'] => 'offboard=revenue:yellow_20|brown_50,groups:Netherlands;'\
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;border=edge:4',
            ['C18'] => 'offboard=revenue:yellow_20|brown_50,hide:1,groups:Netherdlands;path=a:0,b:_0;border=edge:1',
            ['I2'] => 'offboard=revenue:30;label=Est +20;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
            ['I18'] => 'offboard=revenue:0,hide:1;label=x2;path=a:1,b:_0;path=a:2,b:_00',
          },
        }.freeze
      end
    end
  end
end
