# frozen_string_literal: true

module Engine
  module Game
    module G2038
      module Map
        TILES = {
          '2001' =>
          {
            'count' => 12,
            'color' => 'yellow',
            'code' => 'city=revenue:green_10|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;label=N',
          },
          '2002' =>
        {
          'count' => 12,
          'color' => 'yellow',
          'code' => 'city=revenue:green_20|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=N',
        },
          '2003' =>
        {
          'count' => 2,
          'color' => 'yellow',
          'code' => 'city=revenue:green_30|brown_40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=I',
        },
          '2004' =>
        {
          'count' => 4,
          'color' => 'yellow',
          'code' => 'city=revenue:green_40|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=I',
        },
          '2005' =>
        {
          'count' => 8,
          'color' => 'yellow',
          'code' => 'city=revenue:green_50|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=I',
        },
          '2006' =>
        {
          'count' => 2,
          'color' => 'yellow',
          'code' => 'city=revenue:green_20|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=R',
        },
          '2007' =>
        {
          'count' => 4,
          'color' => 'yellow',
          'code' => 'city=revenue:green_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=R',
        },
          '2008' =>
        {
          'count' => 7,
          'color' => 'yellow',
          'code' => 'city=revenue:green_40|brown_70;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                    'path=a:4,b:_0;path=a:5,b:_0;label=R',
        },
          '2009' =>
        {
          'count' => 7,
          'color' => 'yellow',
          'code' => 'city=revenue:green_20|brown_60;city=revenue:green_20|brown_60;path=a:0,b:_0;path=a:0,b:_1;path=a:1,b:_0;path=a:1,b:_1;'\
                    'path=a:2,b:_0;path=a:2,b:_1;path=a:3,b:_0;path=a:3,b:_1;path=a:4,b:_0;path=a:4,b:_1;path=a:5,b:_0;path=a:5,b:_1;label=N/N',
        },
          # TODO: Fill in the rest of these once confirmed (also note that all these lanes should probably be double)
          '2010' =>
        {
          'count' => 2,
          'color' => 'yellow',
          'code' => 'town=revenue:yellow_30|gray_60;town=revenue:20;town=revenue:20;path=a:1,b:_0;path=a:2,b:_0;'\
                    'path=a:4,b:_1;path=a:5,b:_1;path=a:0,b:_2;path=a:3,b:_2',
        },
          '2011' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:yellow_30|gray_60,slots:2;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2012' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2013' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2014' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2015' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2016' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2017' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2018' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2019' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2020' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2021' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
          '2022' =>
        {
          'count' => 1,
          'color' => 'yellow',
          'code' => 'city=revenue:80,slots:4;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:4,b:_0;'\
                    'path=a:5,b:_0;label=I',
        },
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'MM',
          'B6' => 'Torch',
          'D8' => 'RU',
          'D14' => 'Drill Hound',
          'F18' => 'RCC',
          'G7' => 'Fast Buck',
          'H14' => 'Lucky',
          'J2' => 'VP',
          'J18' => 'OCP',
          'K9' => 'TSI',
          'M5' => 'Ore Crusher',
          'M13' => 'Ice Finder',
          'O1' => 'LE',
        }.freeze

        HEXES = {
          gray40: {
            %w[A13 D2 O11] => 'city=revenue:yellow_30|gray_60;path=a:5,b:_0;path=a:0,b:_0',
            %w[H10 H18] => 'city=revenue:yellow_20|gray_70;path=a:5,b:_0;path=a:0,b:_0',
          },
          gray: { %w[A1 B6 D8 D14 F18 G7 H14 J2 J18 K9 M5 M13 O1] => '' },
          blue: {
            %w[
                A3 A5 A7 A9 A11 B2 B4 B8 B10 B12 B14 C1 C3 C5 C7 C9
                C11 C13 C15 D4 D6 D10 D12 D16 E3 E5 E7 E9 E11 E13 E15
                E17 F2 F4 F6 F8 F10 F12 F14 F16 G3 G5 G9 G11 G13 G15
                G17 H4 H6 H8 H12 H16 I3 I5 I7 I9 I11 I13 I15 I17 J4
                J6 J8 J10 J12 J14 J16 K3 K5 K7 K11 K13 K15 K17 L2 L4
                L6 L8 L10 L12 L14 L16 M1 M3 M7 M9 M11 M15 N2 N4 N6 N8
                N10 N12 N14 O3 O5 O7 O9 O13
            ] => '',
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
