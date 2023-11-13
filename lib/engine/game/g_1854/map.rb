# frozen_string_literal: true

module Engine
  module Game
    module G1854
      module Map
        TILES = {
          '3' => 3,
          '4' => 6,
          '5' => 5,
          '6' => 6,
          '7' => 5,
          '8' => 11,
          '9' => 11,
          '14' => 4,
          '15' => 7,
          '16' => 2,
          '19' => 2,
          '20' => 2,
          '23' => 6,
          '24' => 6,
          '25' => 2,
          '26' => 2,
          '27' => 2,
          '28' => 2,
          '29' => 2,
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 1,
          '57' => 6,
          '58' => 6,
          '59' => 2,
          '64' => 1,
          '65' => 1,
          '66' => 1,
          '67' => 1,
          '68' => 1,
          '70' => 1,
          '87' => 2,
          '88' => 2,
          '204' => 2,
          '611' => 6,
          '619' => 4,
          '901' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,loc:0.5;city=revenue:40,loc:2.5;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_1;'\
                      'path=a:3,b:_1;label=L',
          },
          '902' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=L',
          },
          '903' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=L',
          },
          '904' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=B',
          },
          '905' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=B',
          },
          '906' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;label=B',
          },
          '907' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Z',
          },
          '908' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=Z',
          },
          '909' => {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=Z',
          },
          '910' => {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'label=Z',
          },
          '911' => {
            'count' => 2,
            'color' => 'brown',
            'code' => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          '915' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'XM1' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'offboard=revenue:yellow_10|green_20|brown_50|gray_80',
          },
          'XM2' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'offboard=revenue:yellow_10|green_40|brown_50|gray_60',
          },
          'XM3' => {
            'count' => 2,
            'color' => 'gray',
            'code' => 'offboard=revenue:yellow_10|green_50|brown_80|gray_10',
          },
          'X78' => {
            'count' => 5,
            'color' => 'purple',
            'code' => 'path=a:0,b:2,track:narrow',
          },
          'X79' => {
            'count' => 5,
            'color' => 'purple',
            'code' => 'path=a:0,b:3,track:narrow',
          },
          'OP1' => {
            'count' => 1,
            'hidden' => true,
            'color' => 'purple',
            'code' => 'path=a:3,b:5',
          },
          'OP2' => {
            'count' => 3,
            'hidden' => true,
            'color' => 'purple',
            'code' => 'path=a:1,b:4',
          },
          'OP3' => {
            'count' => 1,
            'hidden' => true,
            'color' => 'purple',
            'code' => 'town=revenue:10,loc:4;path=a:0,b:_0;path=a:4,b:_0',
          },
        }.freeze

        LOCATION_NAMES = {
          'A19' => 'Prag',
          'A25' => 'Brunn',
          'D28' => 'Budapest',
        }.freeze

        HEXES = {
          red: {
            ['A19'] => 'offboard=revenue:yellow_20|green_30|brown_50|gray_50;path=a:5,b:_0',
            ['A25'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_40;path=a:5,b:_0',
            ['C27'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:1,b:_0',
            ['D4'] => 'offboard=revenue:yellow_00|green_20|brown_30|gray_40;path=a:0,b:_0',
            ['E1'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:4,b:_0;path=a:5,b:_0',
            ['G1'] => 'offboard=revenue:yellow_20|green_20|brown_20|gray_20;path=a:3,b:_0',
            # TODO: group
            ['D28'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60,groups:Budapest,hide:1;path=a:1,b:_0;border=edge:0',
            ['E27'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60,groups:Budapest;path=a:2,b:_0;border=edge:3',
            ['H10'] => 'offboard=revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0;path=a:3,b:_0',
            ['I15'] => 'offboard=revenue:yellow_20|green_30|brown_40|gray_50;path=a:3,b:_0',
            ['I19'] => 'offboard=revenue:yellow_20|green_30|brown_30|gray_40;path=a:2,b:_0',
          },
          gray: {
            %w[A21 I31 I37] => 'path=a:0,b:5',
            %w[M31 M37] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:3',
            ['C13'] => 'town=revenue:10;path=a:4,b:_0;path=a:_0,b:5',
            ['H12'] => 'town=revenue:10;path=a:2,b:_0;path=a:_0,b:4',
          },
          white: {
            %w[B24 B26 E25 F24 G23 G21 G19 G9 H20 K35 L34 J32] => 'blank',
            %w[F20] => 'upgrade=cost:90,terrain:mountain',
            %w[F10 C25] => 'upgrade=cost:50,terrain:water',
            %w[B16 K31 K29] => 'upgrade=cost:60,terrain:mountain',
            %w[D14 E7 E9 E23 L38] => 'upgrade=cost:70,terrain:mountain',
            %w[G15 H14] => 'upgrade=cost:80,terrain:mountain',
            %w[B20] => 'upgrade=cost:50,terrain:mountain',
            %w[E19 E15] => 'upgrade=cost:90,terrain:mountain',
            %w[E17 E5 F16] => 'upgrade=cost:100,terrain:mountain',
            %w[B18 K33] => 'town=revenue:0;upgrade=cost:50,terrain:mountain',
            %w[L30 L36 K39] => 'town=revenue:0;upgrade=cost:60,terrain:mountain',
            %w[G3] => 'town=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[L32] => 'town=revenue:0;town=revenue:0;upgrade=cost:80,terrain:mountain',
            %w[F2 J30 D24] => 'town=revenue:0;town=revenue:0',
            %w[B22 J36 K37 D22] => 'town=revenue:0;town=revenue:0;upgrade=cost:50,terrain:mountain',
            %w[H16] => 'town=revenue:0;town=revenue:0;upgrade=cost:70,terrain:mountain',
            %w[E21] => 'town=revenue:0;town=revenue:0;upgrade=cost:120,terrain:mountain',
            %w[F4] => 'upgrade=cost:120,terrain:mountain',
            %w[C21 E11] => 'town=revenue:0;town=revenue:0;upgrade=cost:50,terrain:water',
            %w[C19 F6] => 'town=revenue:0;upgrade=cost:50,terrain:water',
            %w[C15 D16 D26] => 'town=revenue:0',
            %w[C17 E3 E13 F22 F8 H18 J34] => 'city=revenue:0',
          },
          yellow: {
            ['C23'] => 'city=revenue:40,loc:0;city=revenue:40,loc:1;city=revenue:40,loc:2;path=a:0,b:_0;path=a:1,b:_1;path=a:2,b:_2',
            ['J38'] => 'city=revenue:20,loc:1;city=revenue:20,loc:5;path=a:1,b:_0;path=a:5,b:_1',
          },
          brown: {
            %w[F12 F14 F18 G17 G13 G11 G7 G5] => 'icon=image:1854/mine',
          },
          purple: {
          },
          blue: {
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
