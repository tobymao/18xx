# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G21Moon
      module Map
        # rubocop:disable Layout/LineLength
        TILES = {
          # Yellow
          '7' => 3,
          '8' => 9,
          '9' => 7,
          '57M' =>
          {
            'count' => 5,
            'color' => 'yellow',
            'code' => 'city=revenue:0;path=a:0,b:_0;path=a:_0,b:3',
          },
          '6M' =>
          {
            'count' => 5,
            'color' => 'yellow',
            'code' => 'city=revenue:0;path=a:0,b:_0;path=a:2,b:_0',
          },
          '5M' =>
          {
            'count' => 4,
            'color' => 'yellow',
            'code' => 'city=revenue:0;path=a:0,b:_0;path=a:1,b:_0',
          },
          'X1' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:0;city=revenue:0;path=a:0,b:_0;path=a:1,b:_1;label=OO',
          },
          'X2' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:0;city=revenue:0;path=a:0,b:_0;path=a:2,b:_1;label=OO',
          },
          'X3' =>
          {
            'count' => 1,
            'color' => 'yellow',
            'code' => 'city=revenue:0;city=revenue:0;path=a:0,b:_0;path=a:3,b:_1;label=OO',
          },

          # Green
          '19' => 1,
          '20' => 1,
          '23' => 1,
          '24' => 1,
          '25' => 1,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '624' => 1,
          '443M' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:0,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '444M' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:0,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          '442M' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:0,slots:2;path=a:0,b:_0;path=a:5,b:_0;path=a:3,b:_0',
          },
          '441M' =>
          {
            'count' => 3,
            'color' => 'green',
            'code' => 'city=revenue:0,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0',
          },
          'X4' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:0;city=revenue:0;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:5;label=OO',
          },
          'X5' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:0;city=revenue:0;path=a:0,b:_0;path=a:_0,b:2;path=a:1,b:_1;path=a:_1,b:3;label=OO',
          },
          'X6' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:0;city=revenue:0;path=a:1,b:_0;path=a:_0,b:5;path=a:2,b:_1;path=a:_1,b:4;label=OO',
          },
          'X7' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:0,loc:0.5;city=revenue:0,loc:2.5;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },

          # Brown
          '39' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          'X8' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:0,b:2;path=a:1,b:3',
          },
          'X9' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:4;path=a:3,b:4',
          },
          'X10' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:4;path=a:0,b:4',
          },
          'X11' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:1,b:4;path=a:1,b:3;path=a:0,b:4',
          },
          'X12' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'path=a:0,b:3;path=a:1,b:3;path=a:0,b:4',
          },
          '449M' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'X13' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'X14' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          'X15' =>
          {
            'count' => 2,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          'X16' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '448M' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'X17' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'X18' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0;city=revenue:0;path=a:0,b:_0;path=a:_0,b:1;path=a:1,b:_1;path=a:_1,b:3;path=a:_0,b:2;path=a:2,b:_1;label=OO',
          },
          'X19' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:2;city=revenue:0;path=a:1,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:4;label=OO',
          },
          'X20' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0,slots:2,loc:0.5;city=revenue:0,slots:2,loc:2.5;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:3;label=OO',
          },
          'X21' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' => 'city=revenue:0;city=revenue:0,slots:2;path=a:0,b:_0;path=a:_0,b:1;path=a:2,b:_1;path=a:_1,b:5;label=OO',
          },

          # Gray
          'X22' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:30,slots:7;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SP',
          },
          'X23' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:40,slots:7;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SP',
          },
          'X24' =>
          {
            'count' => 2,
            'color' => 'gray',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
          },
          'X25' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          'X26' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          'X27' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:0,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          'X28' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:0,slots:2;city=revenue:0,slots:2;path=a:0,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:0,b:_1;path=a:4,b:_1;path=a:5,b:_1;label=OO',
          },
          'X29' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:0,slots:2;city=revenue:0,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:3,b:_1;path=a:4,b:_1;label=OO',
          },
          'X30' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:yellow_30|green_30|brown_40|gray_10,slots:3;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0;label=T;frame=color:#ffa500',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        LOCATION_NAMES = {
          'A3' => 'Space Station',
          'B14' => 'Tourism Colony',
          'L2' => 'Solar Farm',
          'M13' => 'Water Farm',
          'F8' => 'Terminal',
        }.freeze

        # rubocop:disable Layout/LineLength
        HEXES = {
          gray: {
            %w[C3 C5 C9 C13 D8 D14 E1 E7 F10 F14 G11 G15 H8 H12 H14 I9 J4 J6 K3 L12] => '',
            %w[C7 D2 D12 G7 I5 I11 K9] => 'city=revenue:0',
            %w[F8] => 'city=revenue:0;label=T',
            %w[G1] => 'border=edge:5,type:divider',
            %w[G3] => 'border=edge:0,type:divider;border=edge:4,type:divider;border=edge:5,type:divider',
            %w[F4] => 'border=edge:5,type:divider',
            %w[G5] => 'border=edge:1,type:divider;border=edge:2,type:divider;border=edge:3,type:divider',
            %w[E9] => 'city=revenue:20,slots:7;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0;label=SP',
          },
          gray60: {
            %w[B6 C11 F12 H6 J8 J12] => 'upgrade=cost:10,terrain:mountain',
            %w[H4] => 'upgrade=cost:10,terrain:mountain;border=edge:2,type:divider',
          },
          gray50: {
            %w[B8 B10 D4 D6 E3 E11 E13 G9 I3 K7 K11] => 'upgrade=cost:40,terrain:mountain',
            %w[F6] => 'upgrade=cost:40,terrain:mountain;border=edge:4,type:divider',
          },
          red: {
            %w[A7 A9 B4 B12 D10 E15 F2 H10 I7 J2 J10 K5 K13 L10] => 'city=revenue:0;upgrade=cost:20,terrain:mountain',
            %w[H2] => 'city=revenue:0;upgrade=cost:20,terrain:mountain;border=edge:1,type:divider;border=edge:2,type:divider',
            %w[E5 G13] => 'city=revenue:0;city=revenue:0;upgrade=cost:20,terrain:mountain;label=OO',
          },
          purple: {
            %w[B2] => 'offboard=revenue:20,groups:W;path=a:0,b:_0',
            %w[A3] => 'offboard=revenue:20,groups:W;path=a:5,b:_0',
            %w[A5] => 'offboard=revenue:20,groups:W;path=a:0,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[B14] => 'offboard=revenue:20,groups:W;path=a:4,b:_0',
            %w[C15] => 'offboard=revenue:20,groups:W;path=a:3,b:_0;path=a:4,b:_0',
          },
          orange: {
            %w[K1] => 'offboard=revenue:20,groups:E;path=a:0,b:_0',
            %w[L2] => 'offboard=revenue:20,groups:E;path=a:1,b:_0',
            %w[L4] => 'offboard=revenue:20,groups:E;path=a:2,b:_0',
            %w[M11] => 'offboard=revenue:20,groups:E;path=a:1,b:_0',
            %w[M13] => 'offboard=revenue:20,groups:E;path=a:2,b:_0',
            %w[L14] => 'offboard=revenue:20,groups:E;path=a:2,b:_0;path=a:3,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength
        LAYOUT = :flat
      end
    end
  end
end
