# frozen_string_literal: true

module Engine
  module Game
    module G1889
      module Map
        TILES = {
          '3' => 2,
          '5' => 2,
          '6' => 2,
          '7' => 2,
          '8' => 5,
          '9' => 5,
          '12' => 1,
          '13' => 1,
          '14' => 1,
          '15' => 3,
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
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 2,
          '58' => 3,
          '205' => 1,
          '206' => 1,
          '437' => 1,
          '438' => 1,
          '439' => 1,
          '440' => 1,
          '448' => 4,
          '465' => 1,
          '466' => 1,
          '492' => 1,
          '611' => 2,
          'Beg6' => {
            'count' => 2,
            'color' => 'yellow',
            'code' => 'city=revenue:20;path=a:0,b:_0;path=a:2,b:_0',
          },
          'Beg7' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:1',
          },
          'Beg8' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:2',
          },
          'Beg9' => {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'path=a:0,b:3',
          },
          'Beg23' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3;path=a:0,b:4',
          },
          'Beg24' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'path=a:0,b:3;path=a:0,b:2',
          },
        }.freeze

        LOCATION_NAMES = {
          'F3' => 'Saijou',
          'G4' => 'Niihama',
          'H7' => 'Ikeda',
          'A10' => 'Sukumo',
          'J11' => 'Anan',
          'G12' => 'Nahari',
          'E2' => 'Matsuyama',
          'I2' => 'Marugame',
          'K8' => 'Tokushima',
          'C10' => 'Kubokawa',
          'J5' => 'Ritsurin Kouen',
          'G10' => 'Nangoku',
          'J9' => 'Komatsujima',
          'I12' => 'Muki',
          'B11' => 'Nakamura',
          'I4' => 'Kotohira',
          'C4' => 'Ohzu',
          'K4' => 'Takamatsu',
          'B7' => 'Uwajima',
          'B3' => 'Yawatahama',
          'G14' => 'Muroto',
          'F1' => 'Imabari',
          'J1' => 'Sakaide & Okayama',
          'L7' => 'Naruto & Awaji',
          'F9' => 'Kouchi',
        }.freeze

        HEXES = {
          white: {
            %w[D3 H3 J3 B5 C8 E8 I8 D9 I10] => '',
            %w[F3 G4 H7 A10 J11 G12 E2 I2 K8 C10] => 'city=revenue:0',
            ['J5'] => 'town=revenue:0',
            %w[B11 G10 I12 J9] => 'town=revenue:0;icon=image:port',
            ['K6'] => 'upgrade=cost:80,terrain:water',
            %w[H5 I6] => 'upgrade=cost:80,terrain:water|mountain',
            %w[E4 D5 F5 C6 E6 G6 D7 F7 A8 G8 B9 H9 H11 H13] => 'upgrade=cost:80,terrain:mountain',
            ['I4'] => 'city=revenue:0;label=H;upgrade=cost:80',
          },
          yellow: {
            ['C4'] => 'city=revenue:20;path=a:2,b:_0',
            ['K4'] => 'city=revenue:30;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;label=T',
          },
          gray: {
            ['B7'] => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['B3'] => 'town=revenue:20;path=a:0,b:_0;path=a:_0,b:5',
            ['G14'] => 'town=revenue:20;path=a:3,b:_0;path=a:_0,b:4',
            ['J7'] => 'path=a:1,b:5',
          },
          red: {
            ['F1'] => 'offboard=revenue:yellow_30|brown_60|diesel_100;path=a:0,b:_0;path=a:1,b:_0',
            ['J1'] => 'offboard=revenue:yellow_20|brown_40|diesel_80;path=a:0,b:_0;path=a:1,b:_0',
            ['L7'] => 'offboard=revenue:yellow_20|brown_40|diesel_80;path=a:1,b:_0;path=a:2,b:_0',
          },
          green: {
            ['F9'] => 'city=revenue:30,slots:2;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=K;upgrade=cost:80,terrain:water',
          },
        }.freeze

        LAYOUT = :flat
      end
    end
  end
end
