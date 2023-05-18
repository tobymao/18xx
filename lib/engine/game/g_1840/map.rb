# frozen_string_literal: true

module Engine
  module Game
    module G1840
      module Map
        LAYOUT = :pointy

        TILES = {
          '3' => 7,
          '58' => 12,
          '4' => 10,
          '5' => 5,
          '6' => 5,
          '57' => 5,
          '235' => 3,
          '619' => 5,
          '8858' => 1,
          '8859' => 1,
          '8860' => 1,
          '8863' => 1,
          '8864' => 1,
          '8865' => 1,
          '14' => 5,
          '15' => 5,
          '142' => 6,
          '141' => 6,
          '143' => 4,
          '144' => 4,
          '767' => 3,
          '768' => 3,
          '769' => 3,
          '611' => 11,
          '455' => 2,
          'L1' =>
          {
            'count' => 10,
            'color' => 'yellow',
            'code' =>
            'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow;frame=color:#ffa500',
          },
          'L2' =>
          {
            'count' => 11,
            'color' => 'yellow',
            'code' =>
            'town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow;frame=color:#ffa500',
          },
          'L3' =>
          {
            'count' => 2,
            'color' => 'yellow',
            'code' =>
            'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow;frame=color:#ffa500',
          },
          'L4' =>
          {
            'count' => 5,
            'color' => 'yellow',
            'code' =>
            'city=revenue:20;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow;frame=color:#ffa500',
          },
          'L5' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;' \
            'path=a:1,b:_1,track:narrow;path=a:_1,b:5,track:narrow;frame=color:#ffa500',
          },
          'L6' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:3,track:narrow;'\
            'path=a:1,b:_1;path=a:_1,b:5;frame=color:#ffa500',
          },
          'L7' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0,track:narrow;path=a:_0,b:2,track:narrow;' \
            'path=a:1,b:_1;path=a:_1,b:5;frame=color:#ffa500',
          },
          'L8' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;'\
            'path=a:1,b:_1,track:narrow;path=a:_1,b:5,track:narrow;frame=color:#ffa500',
          },
          'L9' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;'\
            'path=a:1,b:_1,track:narrow;path=a:_1,b:4,track:narrow;frame=color:#ffa500',
          },
          'L10' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;'\
            'path=a:2,b:_1,track:narrow;path=a:_1,b:5,track:narrow;frame=color:#ffa500',
          },
          'L11' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:_0,b:1;path=a:_0,b:4;'\
            'path=a:2,b:_0,track:narrow;path=a:_0,b:5,track:narrow;frame=color:#ffa500',
          },
          'L12' =>
          {
            'count' => 2,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:0,b:_0;path=a:_0,b:1;path=a:_0,b:3;'\
            'path=a:2,b:_0,track:narrow;path=a:_0,b:5,track:narrow;frame=color:#ffa500',
          },
          'L13' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:_0,b:2;path=a:_0,b:5;'\
            'path=a:0,b:_0,track:narrow;path=a:_0,b:4,track:narrow;frame=color:#ffa500',
          },
          'L14' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:3,b:_0;path=a:_0,b:2;path=a:_0,b:5;'\
            'path=a:0,b:_0,track:narrow;path=a:_0,b:4,track:narrow;frame=color:#ffa500',
          },
          'L15' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:3;path=a:1,b:_0;path=a:3,b:_0;path=a:_0,b:2;path=a:_0,b:5;'\
            'path=a:0,b:_0,track:narrow;path=a:_0,b:4,track:narrow;frame=color:#ffa500',
          },
          'L16' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:3;path=a:0,b:_0;path=a:_0,b:1;path=a:_0,b:3;path=a:_0,b:4;'\
            'path=a:2,b:_0,track:narrow;path=a:_0,b:5,track:narrow;frame=color:#ffa500',
          },
          'L17' =>
          {
            'count' => 3,
            'color' => 'brown',
            'code' =>
            'city=revenue:60,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=OO',
          },
          'L18' => {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
            'path=a:5,b:_0;label=OO',
          },
          'L19' => {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'town=revenue:10;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          'L20' => {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:yellow_20|green_40|brown_60|gray_80,slots:2;path=a:0,b:_0,terminal:1;' \
            'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;',
          },
          'L21' => {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:yellow_30|green_30|brown_60|gray_90,slots:2;path=a:0,b:_0,terminal:1;'\
            'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;',
          },
          'L22' => {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:yellow_30|green_40|brown_50|gray_70,slots:2;path=a:0,b:_0,terminal:1;'\
            'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;',
          },
          'L23' => {
            'count' => 1,
            'color' => 'red',
            'code' =>
            'city=revenue:yellow_30|green_50|brown_70|gray_30,slots:2;path=a:0,b:_0,terminal:1;'\
            'path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;',
          },
          'L24' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_10|brown_30;town=revenue:yellow_10|brown_30;town=revenue:yellow_10|brown_30;'\
            'town=revenue:yellow_10|brown_30;town=revenue:yellow_10|brown_30;path=a:0,b:_0;path=a:4,b:_0;' \
            'path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:5,b:_4',
          },
          'L25' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_20|brown_20;town=revenue:yellow_20|brown_20;town=revenue:yellow_20|brown_20;'\
            'town=revenue:yellow_20|brown_20;town=revenue:yellow_20|brown_20;path=a:0,b:_0;path=a:4,b:_0;' \
            'path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:5,b:_4',
          },
          'L26' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_30|brown_10;town=revenue:yellow_30|brown_10;town=revenue:yellow_30|brown_10;'\
            'town=revenue:yellow_30|brown_10;town=revenue:yellow_30|brown_10;path=a:0,b:_0;path=a:4,b:_0;' \
            'path=a:1,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:5,b:_4',
          },
          'L27' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_10|brown_30;town=revenue:yellow_10|brown_30;town=revenue:yellow_10|brown_30;'\
            'town=revenue:yellow_10|brown_30;town=revenue:yellow_10|brown_30;path=a:0,b:_0;path=a:1,b:_0;' \
            'path=a:4,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:5,b:_4',
          },
          'L28' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_20|brown_20;town=revenue:yellow_20|brown_20;town=revenue:yellow_20|brown_20;'\
            'town=revenue:yellow_20|brown_20;town=revenue:yellow_20|brown_20;path=a:0,b:_0;path=a:1,b:_0;' \
            'path=a:4,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:5,b:_4',
          },
          'L29' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_30|brown_10;town=revenue:yellow_30|brown_10;town=revenue:yellow_30|brown_10;'\
            'town=revenue:yellow_30|brown_10;town=revenue:yellow_30|brown_10;path=a:0,b:_0;path=a:1,b:_0;' \
            'path=a:4,b:_1;path=a:2,b:_2;path=a:3,b:_3;path=a:5,b:_4',
          },
          'L30a' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_30|brown_10,loc:center;path=a:0,b:_0;path=a:1,b:_0;' \
            'path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'L30b' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_30|brown_10,loc:center;city=revenue:yellow_30|brown_10;' \
            'city=revenue:yellow_30|brown_10;path=a:1,b:_0;path=a:3,b:_0;' \
            'path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_1,track:narrow;path=a:2,b:_2,track:narrow',
          },
          'L31a' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'town=revenue:yellow_10|brown_30,loc:center;path=a:0,b:_0;path=a:0,b:_0;path=a:1,b:_0;' \
            'path=a:2,b:_0;path=a:4,b:_0;path=a:5,b:_0,track:narrow;path=a:3,b:_0,track:narrow',
          },
          'L31b' => {
            'count' => 1,
            'color' => 'purple',
            'code' =>
            'city=revenue:yellow_10|brown_30;city=revenue:yellow_10|brown_30;' \
            'town=revenue:yellow_10|brown_30,loc:center;path=a:1,b:_2;path=a:3,b:_2;' \
            'path=a:4,b:_2;path=a:5,b:_2;path=a:0,b:_0,track:narrow;path=a:2,b:_1,track:narrow',
          },

        }.freeze

        HEXES = {
          gray: {
            ['A7'] => 'town=revenue:10;path=a:0,b:_0;path=a:5,b:_0',
            ['A9'] => 'town=revenue:20;path=a:5,b:_0',
            ['A25'] => 'town=revenue:10;path=a:5,b:_0',
            ['A27'] => 'town=revenue:10;path=a:0,b:_0',
            ['K21'] => 'town=revenue:10;path=a:3,b:_0',
            ['K23'] => 'town=revenue:10;path=a:2,b:_0',
            ['F2'] => 'town=revenue:10;path=a:3,b:_0;path=a:4,b:_0',
            %w[B22 H22] => 'town=revenue:20;path=a:4,b:_0;path=a:5,b:_0',
            ['K7'] => 'town=revenue:20;path=a:2,b:_0;path=a:3,b:_0',
            %w[H30 C29] => 'town=revenue:10;path=a:1,b:_0;path=a:2,b:_0',
            ['F30'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0',
            ['D28'] => 'town=revenue:20;path=a:0,b:_0;path=a:1,b:_0',
            ['F8'] => 'town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;town=revenue:10;path=a:2,b:_1;path=a:3,b:_1' \
                      'border=edge:4',
            ['F10'] => 'town=revenue:10;path=a:4,b:_0;path=a:5,b:_0;town=revenue:10;path=a:2,b:_1;path=a:3,b:_1' \
                       'border=edge:1',
            ['A19'] => 'town=revenue:30;path=a:1,b:_0,track:narrow;path=a:5,b:_0,track:narrow',
            ['C7'] => 'city=revenue:30,slots:2;path=a:0,b:_0,track:narrow;path=a:4,b:_0,track:narrow;' \
                      'path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:5,b:_0',
            ['I11'] => 'city=revenue:30;town=revenue:10;town=revenue:30;path=a:3,b:_0,track:narrow;path=a:1,b:_2,track:narrow;' \
                       'path=a:0,b:_1;path=a:5,b:_1;path=a:4,b:_2,track:narrow',
          },
          white: {
            %w[B4 B6 B8 B18 B24 C3 C5 C11 C19 C23 C25 C27 D2 D8 D10 D14 D16 E5 E9 E25 E27 F4 F16 F26 G7 G9 G13 G27 G29
               H4 H6 H8 H14 H18 H24 H26 I17 I19 I23 I25 I29 J6 J8 J12 J14 J18 J20 J24] => '',
            %w[B12 C15 D4 D24 D26 E3 E11 E15 F14 F18 F20 F22 F28 G15 G25 H20 H28 I21 J10 J16 J26 J28] =>
            'city=revenue:0',
            ['B28'] => 'upgrade=cost:40,terrain:water',
            %w[H10 D18 E17] =>
            'city=revenue:0;city=revenue:0;label=OO',
            %w[D12] => 'city=revenue:0;path=track:future,a:3,b:_0;path=track:future,a:5,b:_0;' \
                       'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/green_hex',
            %w[I9] => 'city=revenue:0;path=track:future,a:1,b:_0;path=track:future,a:_0,b:4;' \
                      'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/green_hex',
            %w[B10] => 'city=revenue:0;path=track:future,a:0,b:_0;path=track:future,a:3,b:_0;' \
                       'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[D22] => 'city=revenue:0;path=track:future,a:2,b:_0;path=track:future,a:_0,b:5;' \
                       'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[E23] => 'city=revenue:0;path=track:future,a:2,b:_0;path=track:future,a:_0,b:5;' \
                       'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/token',
            %w[F6] => 'city=revenue:0;path=track:future,a:0,b:_0;path=track:future,a:3,b:_0;' \
                      'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/token',
            %w[I15] => 'city=revenue:0;path=track:future,a:1,b:_0;path=track:future,a:_0,b:3;' \
                       'upgrade=cost:20;frame=color:#ffa500;icon=image:1840/token',
            %w[C9] => 'path=track:future,a:1,b:3;upgrade=cost:20;' \
                      'frame=color:#ffa500;icon=image:1840/green_hex',
            %w[E7] => 'path=track:future,a:0,b:2;upgrade=cost:20;' \
                      'frame=color:#ffa500;icon=image:1840/green_hex',
            %w[H16] => 'path=track:future,a:0,b:3;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/green_hex',
            %w[B14] => 'path=track:future,a:0,b:4;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/red_hex',
            %w[C21] => 'path=track:future,a:2,b:5;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/red_hex',
            %w[I3] => 'path=track:future,a:1,b:4;upgrade=cost:20;' \
                      'frame=color:#ffa500;icon=image:1840/red_hex',
            %w[I7] => 'path=track:future,a:1,b:4;upgrade=cost:20;' \
                      'frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[I13] => 'path=track:future,a:1,b:4;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[B16] => 'path=track:future,a:1,b:3;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[F12] => 'path=track:future,a:0,b:3;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[H12] => 'path=track:future,a:0,b:2;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[G23] => 'path=track:future,a:1,b:3;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[G19] => 'path=track:future,a:1,b:4;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/yellow_hex',
            %w[B20] => 'path=track:future,a:2,b:5;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/purple_hex',
            %w[C13] => 'path=track:future,a:0,b:3;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/purple_hex',
            %w[G5] => 'path=track:future,a:1,b:3;upgrade=cost:20;' \
                      'frame=color:#ffa500;icon=image:1840/purple_hex',
            %w[G21] => 'path=track:future,a:1,b:4;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/purple_hex',
            %w[I5] => 'path=track:future,a:1,b:4;upgrade=cost:20;' \
                      'frame=color:#ffa500;icon=image:1840/purple_hex',
            %w[D6] => 'path=track:future,a:3,b:5;upgrade=cost:20;' \
                      'frame=color:#ffa500;icon=image:1840/token',
            %w[E13] => 'path=track:future,a:0,b:2;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/token',
            %w[G17] => 'path=track:future,a:0,b:4;upgrade=cost:20;' \
                       'frame=color:#ffa500;icon=image:1840/token',
          },
          yellow: {

          },

          red: {
            ['D20'] => 'border=edge:0,type:impassable;border=edge:5,type:impassable;'\
                       'offboard=revenue:yellow_0,visit_cost:0;path=a:2,b:_0;' \
                       'path=a:3,b:_0;path=a:4,b:_0;path=a:1,b:_0',
            ['E19'] => 'border=edge:3,type:impassable;border=edge:4,type:impassable;' \
                       'offboard=revenue:yellow_0,visit_cost:0;path=a:0,b:_0;path=a:1,b:_0;' \
                       'path=a:2,b:_0;path=a:5,b:_0',
            ['E21'] => 'border=edge:1,type:impassable;border=edge:2,type:impassable;'\
                       'offboard=revenue:yellow_0,visit_cost:0;path=a:0,b:_0;path=a:3,b:_0;' \
                       'path=a:4,b:_0;path=a:5,b:_0',
            ['K9'] =>
            'city=slots:2,revenue:yellow_30|green_40|brown_50|gray_60;path=a:2,b:_0,terminal:1;'\
            'path=a:3,b:_0,terminal:1;path=a:4,b:_0,lanes:2,terminal:1;border=edge:1;border=edge:4',
            ['K11'] =>
            'path=a:1,b:2,a_lane:2.0;path=a:1,b:3,a_lane:2.1;border=edge:1',
            ['K15'] =>
            'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;'\
            'path=a:2,b:_0,terminal:1;path=a:3,terminal:1,b:_0;path=a:4,b:_0,terminal:1,lanes:2;border=edge:1;'\
            'border=edge:4',
            ['K17'] =>
            'path=a:1,b:2,a_lane:2.0;path=a:1,b:3,a_lane:2.1;border=edge:1',
            ['K27'] =>
            'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;'\
            'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1;border=edge:4',
            ['K29'] =>
                'path=a:2,b:1;border=edge:1',
            ['J4'] =>
               'city=revenue:yellow_30|green_50|brown_60|gray_80,slots:2;'\
               'path=a:2,b:_0,terminal:1;path=a:3,b:_0,terminal:1;path=a:4,b:_0,terminal:1',
            ['A29'] =>
                'city=revenue:yellow_30|green_40|brown_60|gray_70,slots:2;'\
                'path=a:0,b:_0,terminal:1',
            ['A21'] =>
            'city=revenue:yellow_20|green_30|brown_40|gray_50,slots:2;'\
            'path=a:0,b:_0,terminal:1;path=a:4,b:_0,terminal:1;border=edge:4',
            ['A23'] =>
               'path=a:5,b:1;border=edge:1',
            ['B2'] =>
                 'city=revenue:yellow_30|green_40|brown_60|gray_70,slots:2;border=edge:3;'\
                 'path=a:4,b:_0,terminal:1;path=a:5,b:_0,terminal:1;path=a:3,b:_0,terminal:1',
            ['A3'] =>
                 'path=a:0,b:5;border=edge:0',
            ['I1'] =>
                 'city=revenue:yellow_20|green_30|brown_40|gray_50;'\
                 'path=a:4,b:_0,track:narrow,terminal:1;',

            ['A17'] =>
                   'city=revenue:40;city=revenue:40;city=revenue:40;path=a:0,b:_0,track:narrow;' \
                   'path=a:1,b:_1,track:narrow;path=a:4,b:_2,track:narrow;',
            ['A13'] =>
                   'city=revenue:30,slots:2;path=a:0,b:_0;path=a:5,b:_0;' \
                   'path=a:1,b:_0,track:narrow;path=a:4,b:_0,track:narrow;',
            ['A15'] => 'path=a:1,b:4,track:narrow',
            ['A11'] => 'path=a:0,b:4,track:narrow',
            ['G3'] =>
                 'city=revenue:yellow_30|green_40|brown_50|gray_60,slots:2;'\
                 'path=a:3,b:_0,terminal:1;path=a:5,terminal:1,b:_0;path=a:4,b:_0,terminal:1,track:narrow',
          },

          purple: {
            ['F24'] =>
            'offboard=revenue:yellow_0;city=revenue:20;city=revenue:20;'\
            'path=a:0,b:_1,track:narrow;path=a:1,b:_0;path=a:2,b:_2,track:narrow;' \
            'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[C17 I27 J22 B26] =>
            'offboard=revenue:yellow_0,visit_cost:0;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;' \
            'path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['G11'] =>
              'offboard=revenue:yellow_0;town=revenue:10;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;'\
              'path=a:3,b:_1,track:narrow;path=a:4,b:_0;path=a:5,b:_1,track:narrow',
          },
        }.freeze

        LOCATION_NAMES = {
          'A3' => 'Neustift am Walde',
          'A13' => 'Grinzing',
          'A17' => 'Heiligenstadt',
          'A23' => 'Brigittenau',
          'A29' => 'Kagran',
          'B10' => 'Gersthof',
          'B12' => 'Döbling',
          'B22' => 'Augarten',
          'B26' => 'Nordbahnhof',
          'C7' => 'Hernals',
          'C15' => 'Alsergrund',
          'C17' => 'Franz Josef-Bahnhof',
          'C29' => 'Donaubäder',
          'D4' => 'Dornbach',
          'D12' => 'Währing',
          'D18' => 'Schottentor & Universität',
          'D20' => 'Stephansdom',
          'D22' => 'Schwedenplatz',
          'D24' => 'Leopoldstadt',
          'D26' => 'Praterstern',
          'D28' => 'Prater',
          'E3' => 'Ottakring',
          'E11' => 'Neulerchenfeld',
          'E15' => 'Josefstadt',
          'E17' => 'Rathaus & Parlament',
          'E19' => 'Hofburg',
          'E21' => 'Karlskirche',
          'E23' => 'Stubentor',
          'F6' => 'Breitensee',
          'F8' => 'Auf der Schmelz',
          'F14' => 'Neubau',
          'F18' => 'Museum',
          'F20' => 'Oper',
          'F22' => 'Stadtpark',
          'F24' => 'Bahnhof Hauptzollamt',
          'F28' => 'Weißgerber',
          'F30' => 'Lände',
          'G3' => 'Penzing',
          'G11' => 'Westbahnhof',
          'G15' => 'Mariahilf',
          'G25' => 'Landstraße',
          'H10' => 'Rudolfsheim & Fünfhaus',
          'H20' => 'Wieden',
          'H22' => 'Schloss Belvedere',
          'H28' => 'Erdberg',
          'I1' => 'Hütteldorf',
          'I9' => 'Gaudenzdorf',
          'I11' => 'Wien',
          'I15' => 'Margareten',
          'I21' => 'Nikolsdorf',
          'I27' => 'Aspangbahnhof',
          'J4' => 'Hietzing',
          'J10' => 'Meidling',
          'J16' => 'Matzleinsdorf',
          'J22' => 'Südbahnhof',
          'J26' => 'Arsenal',
          'J28' => 'Sankt Marx',
          'K7' => 'Schloss Schönbrunn',
          'K27' => 'Simmering',
          'K9' => 'Liesing',
          'K15' => 'Favoriten',
        }.freeze
      end
    end
  end
end
