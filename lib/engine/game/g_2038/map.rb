# frozen_string_literal: true

module Engine
  module Game
    module G2038
      module Map
        # Shared path segments for tile code strings.
        # BX6: all 6 edges - junction(_0) only; used by unexplored blue hexes.
        # SP6: all 6 edges - junction(_0) + city(_1); used by single-mine tiles.
        # DP6: all 6 edges - junction(_0) + city1(_1) + city2(_2); used by double-mine tiles.
        BX6 = 'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0'
        SP6 = 'path=a:0,b:_0;path=a:0,b:_1;path=a:1,b:_0;path=a:1,b:_1;path=a:2,b:_0;path=a:2,b:_1;'\
              'path=a:3,b:_0;path=a:3,b:_1;path=a:4,b:_0;path=a:4,b:_1;path=a:5,b:_0;path=a:5,b:_1'
        DP6 = 'path=a:0,b:_0;path=a:0,b:_1;path=a:0,b:_2;path=a:1,b:_0;path=a:1,b:_1;path=a:1,b:_2;'\
              'path=a:2,b:_0;path=a:2,b:_1;path=a:2,b:_2;path=a:3,b:_0;path=a:3,b:_1;path=a:3,b:_2;'\
              'path=a:4,b:_0;path=a:4,b:_1;path=a:4,b:_2;path=a:5,b:_0;path=a:5,b:_1;path=a:5,b:_2'

        TILES = {
          # Single-mine N tiles
          '2001' => {
            'count' => 12,
            'color' => 'gray',
            # real revenue: unclaimed 10, claimed 50
            'code' => "junction;city=revenue:42;#{SP6};label=N",
          },
          '2002' => {
            'count' => 12,
            'color' => 'gray',
            # real revenue: unclaimed 20, claimed 60
            'code' => "junction;city=revenue:42;#{SP6};label=N",
          },
          # Single-mine I tiles
          '2003' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: unclaimed 30, claimed 40
            'code' => "junction;city=revenue:42;#{SP6};label=I",
          },
          '2004' => {
            'count' => 4,
            'color' => 'gray',
            # real revenue: unclaimed 40, claimed 50
            'code' => "junction;city=revenue:42;#{SP6};label=I",
          },
          '2005' => {
            'count' => 8,
            'color' => 'gray',
            # real revenue: unclaimed 50, claimed 60
            'code' => "junction;city=revenue:42;#{SP6};label=I",
          },
          # Single-mine R tiles
          '2006' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: unclaimed 20, claimed 50
            'code' => "junction;city=revenue:42;#{SP6};label=R",
          },
          '2007' => {
            'count' => 4,
            'color' => 'gray',
            # real revenue: unclaimed 30, claimed 60
            'code' => "junction;city=revenue:42;#{SP6};label=R",
          },
          '2008' => {
            'count' => 6,
            'color' => 'gray',
            # real revenue: unclaimed 40, claimed 70
            'code' => "junction;city=revenue:42;#{SP6};label=R",
          },
          # N/N double-mine tiles (NdNm first, then NdNd)
          '2009' => {
            'count' => 12,
            'color' => 'gray',
            # real revenue: city1 unclaimed 20/claimed 60, city2 unclaimed 10/claimed 50
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=N/N",
          },
          '2010' => {
            'count' => 8,
            'color' => 'gray',
            # real revenue: city1 unclaimed 20/claimed 60, city2 unclaimed 20/claimed 60
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=N/N",
          },
          # I/N double-mine tiles
          '2011' => {
            'count' => 6,
            'color' => 'gray',
            # real revenue: city1 unclaimed 30/claimed 40, city2 unclaimed 10/claimed 50
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=I/N",
          },
          '2012' => {
            'count' => 4,
            'color' => 'gray',
            # real revenue: city1 unclaimed 30/claimed 40, city2 unclaimed 20/claimed 60
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=I/N",
          },
          '2013' => {
            'count' => 4,
            'color' => 'gray',
            # real revenue: city1 unclaimed 40/claimed 50, city2 unclaimed 10/claimed 50
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=I/N",
          },
          '2014' => {
            'count' => 4,
            'color' => 'gray',
            # real revenue: city1 unclaimed 40/claimed 50, city2 unclaimed 20/claimed 60
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=I/N",
          },
          # R/N double-mine tiles
          '2015' => {
            'count' => 4,
            'color' => 'gray',
            # real revenue: city1 unclaimed 20/claimed 50, city2 unclaimed 10/claimed 50
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/N",
          },
          '2016' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: city1 unclaimed 20/claimed 50, city2 unclaimed 20/claimed 60
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/N",
          },
          '2017' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: city1 unclaimed 30/claimed 60, city2 unclaimed 10/claimed 50
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/N",
          },
          '2018' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: city1 unclaimed 30/claimed 60, city2 unclaimed 20/claimed 60
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/N",
          },
          # R/I double-mine tiles
          '2019' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: city1 unclaimed 20/claimed 50, city2 unclaimed 30/claimed 40
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/I",
          },
          '2020' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: city1 unclaimed 20/claimed 50, city2 unclaimed 40/claimed 50
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/I",
          },
          '2021' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: city1 unclaimed 30/claimed 60, city2 unclaimed 30/claimed 40
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/I",
          },
          '2022' => {
            'count' => 2,
            'color' => 'gray',
            # real revenue: city1 unclaimed 30/claimed 60, city2 unclaimed 40/claimed 50
            'code' => "junction;city=revenue:42;city=revenue:42;#{DP6};label=R/I",
          },
          # Gray base tile - placed when a corporation establishes a base on an explored asteroid.
          # The city slot holds the base token; revenue is tracked via corporation base mechanics.
          '2023' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => "junction;city=revenue:0;#{SP6}",
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
          'J18' => 'OPC',
          'K9' => 'TSI',
          'M5' => 'Ore Crusher',
          'M13' => 'Ice Finder',
          'O1' => 'LE',
        }.freeze

        HEXES = {
          gray40: {
            %w[A13 D2 H10
               O11] => 'city=revenue:yellow_30|gray_60;'\
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            %w[H18] => 'city=revenue:yellow_20|gray_70;'\
                       'path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
          gray: { %w[A1 B6 D8 D14 F18 G7 H14 J2 J18 K9 M5 M13 O1] => "junction;city=revenue:0;#{SP6}" },
          blue: {
            %w[
                A3 A5 A7 A9 A11 B2 B4 B8 B10 B12 B14 C1 C3 C5 C7 C9
                C11 C13 C15 D4 D6 D10 D12 D16 E3 E5 E7 E9 E11 E13 E15
                E17 F2 F4 F6 F8 F10 F12 F14 F16 G3 G5 G9 G11 G13 G15
                G17 H4 H6 H8 H12 H16 I3 I5 I7 I9 I11 I13 I15 I17 J4
                J6 J8 J10 J12 J14 J16 K3 K5 K7 K11 K13 K15 K17 L2 L4
                L6 L8 L10 L12 L14 L16 M1 M3 M7 M9 M11 M15 N2 N4 N6 N8
                N10 N12 N14 O3 O5 O7 O9 O13
            ] => "junction;#{BX6}",
          },
        }.freeze

        LAYOUT = :pointy
      end
    end
  end
end
