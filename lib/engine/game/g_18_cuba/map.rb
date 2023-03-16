# frozen_string_literal: true

module Engine
  module Game
    module G18Cuba
      module Map
        TILES = {
          '7' => 2,
          '8' => 9,
          '9' => 9,
          '5' => 3,
          '57' => 3,
          '6' => 3,
          '201' => 1,
          '621' => 1,
          '202' => 1,
          '77' => 6,
          '78' => 4,
          '79' => 4,
          'L48' =>
          {
            'count' => 8,
            'color' => 'yellow',
            'code' =>
              'town=revenue:10;path=a:2,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'L49' =>
          {
            'count' => 8,
            'color' => 'yellow',
            'code' =>
              'town=revenue:10;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'L50' =>
          {
            'count' => 6,
            'color' => 'yellow',
            'code' =>
              'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
          },
          'L52' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0',
            },
          'L53' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:4,b:_0,track:narrow;path=a:0,b:_0;path=a:5,b:_0',
            },
          'L54' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0;path=a:5,b:_0',
            },
          'L55' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:3,b:_0,track:narrow;path=a:1,b:_0;path=a:5,b:_0',
            },
          'L56' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:2,b:_0,track:narrow;path=a:1,b:_0;path=a:5,b:_0',
            },
          'L57' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:2,b:_0,track:narrow;path=a:3,b:_0;path=a:5,b:_0',
            },
          'L58' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:3,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0',
            },
          'L59' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:1,b:_0,track:narrow;path=a:2,b:_0;path=a:5,b:_0',
            },
          'L60' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:1,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0',
            },
          'L61' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' =>
                'city=revenue:20;path=a:2,b:_0,track:narrow;path=a:4,b:_0;path=a:5,b:_0',
            },

          # green
          '16' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 3,
          '24' => 3,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '619' => 3,
          '14' => 3,
          '15' => 3,
          '622' => 1,
          '208' => 1,
          '207' => 1,
          'L44' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=H',
            },
          'L45' =>
            {
              'count' => 1,
              'color' => 'green',
              'code' =>
                'city=revenue:40;city=revenue:40;city=revenue:40;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;'\
                'path=a:4,b:_1;path=a:5,b:_2;path=a:0,b:_2;label=H',
            },
          '710' => 2,
          '712' => 2,
          '713' => 2,
          '711' => 2,
          '714' => 2,
          '715' => 2,
          'IR26' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:3;path=a:1,b:2,track:narrow' },
          'IR27' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:3,track:narrow;path=a:1,b:2' },
          'IR28' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:1,b:3,track:narrow;path=a:0,b:4' },
          'IR29' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1,track:narrow;path=a:2,b:4' },
          'IR30' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:1,b:2,track:narrow;path=a:0,b:4' },
          'IR31' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:1,b:2;path=a:0,b:4,track:narrow' },
          'IR32' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1;path=a:2,b:4,track:narrow' },
          'IR33' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1;path=a:2,b:3,track:narrow' },
          'IR34' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1,track:narrow;path=a:3,b:4' },
          'IR35' => { 'count' => 1, 'color' => 'green', 'code' => 'path=a:0,b:1,track:narrow;path=a:2,b:3' },
          'L62' =>
            {
              'count' => 3,
              'color' => 'green',
              'code' =>
                'town=revenue:20;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L63' =>
            {
              'count' => 3,
              'color' => 'green',
              'code' =>
                'town=revenue:20;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L64' =>
            {
              'count' => 9,
              'color' => 'green',
              'code' =>
                'town=revenue:20;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L65' =>
            {
              'count' => 9,
              'color' => 'green',
              'code' =>
                'town=revenue:20;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L66' =>
            {
              'count' => 6,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:3;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;',
            },
          'L67' =>
            {
              'count' => 6,
              'color' => 'green',
              'code' =>
                'city=revenue:30,slots:3;path=a:0,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;',
            },

          # brown
          '39' => 2,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 2,
          '70' => 2,
          '44' => 2,
          '47' => 2,
          '45' => 2,
          '46' => 2,
          '611' => 4,
          '216' => 2,
          'L46' =>
            {
              'count' => 1,
              'color' => 'brown',
              'code' =>
                'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=H',
            },
          'L68' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'town=revenue:30;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L69' =>
            {
              'count' => 2,
              'color' => 'brown',
              'code' =>
                'town=revenue:30;path=a:2,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L70' =>
            {
              'count' => 6,
              'color' => 'brown',
              'code' =>
                'town=revenue:30;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L71' =>
            {
              'count' => 6,
              'color' => 'brown',
              'code' =>
                'town=revenue:30;path=a:1,b:_0,track:narrow;path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L72' =>
            {
              'count' => 5,
              'color' => 'brown',
              'code' =>
                'city=revenue:40,slots:3;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;',
            },
          'L73' =>
            {
              'count' => 5,
              'color' => 'brown',
              'code' =>
                'city=revenue:40,slots:3;path=a:0,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;',
            },

          # gray
          '455' => 1,
          '512' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
              'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            },
          'L47' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:80,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
                'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=H',
            },
          'L74' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'town=revenue:40;path=a:0,b:_0,track:narrow;path=a:1,b:_0,track:narrow;'\
                'path=a:2,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L75' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'town=revenue:40;path=a:1,b:_0,track:narrow;path=a:2,b:_0,track:narrow;'\
                'path=a:3,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            },
          'L76' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:3,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:5,b:_0;',
            },
          'L77' =>
            {
              'count' => 1,
              'color' => 'gray',
              'code' =>
                'city=revenue:50,slots:3;path=a:0,b:_0,track:narrow;path=a:4,b:_0,track:narrow;'\
                'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0;',
            },

        }.freeze

        TILE_GROUPS = [
          %w[7],
          %w[8 9],
          %w[5 57],
          %w[6],
          %w[201 621],
          %w[202],
          %w[L52 L53],
          %w[L54 L55],
          %w[L56 L57],
          %w[L58 L59],
          %w[L60 L61],
          %w[77 L50],
          %w[78 79],
          %w[L48 L49],
          %w[16 18],
          %w[19 20],
          %w[23 24],
          %w[25],
          %w[26 27],
          %w[28 29],
          %w[30 31],
          %w[619],
          %w[14 15],
          %w[L44 L45],
          %w[622],
          %w[208 207],
          %w[L66 L67],
          %w[710 712],
          %w[713 711],
          %w[714 715],
          %w[IR26 IR27],
          %w[IR28 IR34],
          %w[IR33 IR35],
          %w[IR29 IR30],
          %w[IR31 IR32],
          %w[L62 L63],
          %w[L64 L65],
          %w[39 40],
          %w[41 42],
          %w[43 70],
          %w[44 47],
          %w[45 46],
          %w[611],
          %w[216],
          %w[L46],
          %w[L68 L69],
          %w[L70 L71],
          %w[L72 L73],
          %w[455],
          %w[512],
          %w[L47],
          %w[L74 L75],
          %w[L76 L77],
        ].freeze

        LOCATION_NAMES = {
          'B7' => 'Havana',
          'B9' => 'Matanzas',
          'B11' => 'Cardenas',
          'C4' => 'Pinar del Rio',
          'C14' => 'Santa Clara',
          'D13' => 'Cienfuegos',
          'D15' => 'Sancti Spiritus',
          'D19' => 'Camagüey',
          'E22' => 'Las Tunas',
          'E24' => 'Holguin',
          'F21' => 'Bayamo',
          'G24' => 'Santiago de Cuba',
          'G26' => 'Guantánamo',
        }.freeze

        HEXES = {

          white: {
            %w[D1 C2 E2 D5 D11 B13 C16 C18 E16 E18 G22 H21 D21 F29
               G28] => 'icon=image:18_cuba/sugar-cane;upgrade=cost:10',
            %w[D3 B5 C6 C10 C12 B15 D17 E20 F23 F25] => '',
            %w[C4 C14 B9 B11 D13 D15 D19 E22 F21 G26] => 'city=revenue:0',
            %w[E24 G24] => 'city=revenue:0;label=Y',
            %w[D9 G20 F27] => 'icon=image:18_cuba/sugar-cane;upgrade=cost:10;border=edge:2,type:impassable',
            %w[F19 E26] => 'icon=image:18_cuba/sugar-cane;upgrade=cost:10;border=edge:5,type:impassable',
            ['C8'] => 'border=edge:5,type:impassable',
          },
          yellow: {
            ['B7'] => 'city=revenue:20;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=H',
          },
          blue: {
            %w[B3 A6] => 'offboard=revenue:10;path=a:5,b:_0;icon=image:anchor',
            %w[A12 C20 D25] => 'offboard=revenue:10;path=a:0,b:_0;icon=image:anchor',
            %w[A8 A10 D23] => 'offboard=revenue:10;path=a:0,b:_0;path=a:5,b:_0;icon=image:anchor',
            %w[E4 H27] => 'offboard=revenue:10;path=a:2,b:_0;icon=image:anchor',
            %w[E12 H23] => 'offboard=revenue:10;path=a:3,b:_0;icon=image:anchor',
            %w[E14 H25] => 'offboard=revenue:10;path=a:2,b:_0;path=a:3,b:_0;icon=image:anchor',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
