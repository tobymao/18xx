# frozen_string_literal: true

module Engine
  module Game
    module G2038
      module Map
        # Not a real track connection -- this game has none (see
        # IMPASSABLE_HEX_COLORS). Exists only so a double-mine tile's two
        # cities respect rotation.
        MINE_LINK = 'path=a:_0,b:_1,track:thin'

        # 'color' here is not rendered -- view/game/hex_g2038.rb draws the
        # starfield/icon art instead.

        TILES = {
          # Single-mine N tiles
          '2001' => {
            'count' => 12,
            'color' => 'gray',
            # unclaimed 10 / claimed 50
            'code' => 'city=revenue:10',
          },
          '2002' => {
            'count' => 12,
            'color' => 'gray',
            # unclaimed 20 / claimed 60
            'code' => 'city=revenue:20',
          },
          # Single-mine I tiles
          '2003' => {
            'count' => 2,
            'color' => 'gray',
            # unclaimed 30 / claimed 40
            'code' => 'city=revenue:30',
          },
          '2004' => {
            'count' => 4,
            'color' => 'gray',
            # unclaimed 40 / claimed 50
            'code' => 'city=revenue:40',
          },
          '2005' => {
            'count' => 8,
            'color' => 'gray',
            # unclaimed 50 / claimed 60
            'code' => 'city=revenue:50',
          },
          # Single-mine R tiles
          '2006' => {
            'count' => 2,
            'color' => 'gray',
            # unclaimed 20 / claimed 50
            'code' => 'city=revenue:20',
          },
          '2007' => {
            'count' => 4,
            'color' => 'gray',
            # unclaimed 30 / claimed 60
            'code' => 'city=revenue:30',
          },
          '2008' => {
            'count' => 6,
            'color' => 'gray',
            # unclaimed 40 / claimed 70
            'code' => 'city=revenue:40',
          },
          # N/N double-mine tiles (NdNm first, then NdNd)
          '2009' => {
            'count' => 12,
            'color' => 'gray',
            # city1 unclaimed 20/claimed 60, city2 unclaimed 10/claimed 50
            'code' => "city=revenue:20,loc:0;city=revenue:10,loc:3;#{MINE_LINK}",
          },
          '2010' => {
            'count' => 8,
            'color' => 'gray',
            # city1 unclaimed 20/claimed 60, city2 unclaimed 20/claimed 60
            'code' => "city=revenue:20,loc:0;city=revenue:20,loc:3;#{MINE_LINK}",
          },
          # I/N double-mine tiles
          '2011' => {
            'count' => 6,
            'color' => 'gray',
            # city1 unclaimed 30/claimed 40, city2 unclaimed 10/claimed 50
            'code' => "city=revenue:30,loc:0;city=revenue:10,loc:3;#{MINE_LINK}",
          },
          '2012' => {
            'count' => 4,
            'color' => 'gray',
            # city1 unclaimed 30/claimed 40, city2 unclaimed 20/claimed 60
            'code' => "city=revenue:30,loc:0;city=revenue:20,loc:3;#{MINE_LINK}",
          },
          '2013' => {
            'count' => 4,
            'color' => 'gray',
            # city1 unclaimed 40/claimed 50, city2 unclaimed 10/claimed 50
            'code' => "city=revenue:40,loc:0;city=revenue:10,loc:3;#{MINE_LINK}",
          },
          '2014' => {
            'count' => 4,
            'color' => 'gray',
            # city1 unclaimed 40/claimed 50, city2 unclaimed 20/claimed 60
            'code' => "city=revenue:40,loc:0;city=revenue:20,loc:3;#{MINE_LINK}",
          },
          # R/N double-mine tiles
          '2015' => {
            'count' => 4,
            'color' => 'gray',
            # city1 unclaimed 20/claimed 50, city2 unclaimed 10/claimed 50
            'code' => "city=revenue:20,loc:0;city=revenue:10,loc:3;#{MINE_LINK}",
          },
          '2016' => {
            'count' => 2,
            'color' => 'gray',
            # city1 unclaimed 20/claimed 50, city2 unclaimed 20/claimed 60
            'code' => "city=revenue:20,loc:0;city=revenue:20,loc:3;#{MINE_LINK}",
          },
          '2017' => {
            'count' => 2,
            'color' => 'gray',
            # city1 unclaimed 30/claimed 60, city2 unclaimed 10/claimed 50
            'code' => "city=revenue:30,loc:0;city=revenue:10,loc:3;#{MINE_LINK}",
          },
          '2018' => {
            'count' => 2,
            'color' => 'gray',
            # city1 unclaimed 30/claimed 60, city2 unclaimed 20/claimed 60
            'code' => "city=revenue:30,loc:0;city=revenue:20,loc:3;#{MINE_LINK}",
          },
          # R/I double-mine tiles
          '2019' => {
            'count' => 2,
            'color' => 'gray',
            # city1 unclaimed 20/claimed 50, city2 unclaimed 30/claimed 40
            'code' => "city=revenue:20,loc:0;city=revenue:30,loc:3;#{MINE_LINK}",
          },
          '2020' => {
            'count' => 2,
            'color' => 'gray',
            # city1 unclaimed 20/claimed 50, city2 unclaimed 40/claimed 50
            'code' => "city=revenue:20,loc:0;city=revenue:40,loc:3;#{MINE_LINK}",
          },
          '2021' => {
            'count' => 2,
            'color' => 'gray',
            # city1 unclaimed 30/claimed 60, city2 unclaimed 30/claimed 40
            'code' => "city=revenue:30,loc:0;city=revenue:30,loc:3;#{MINE_LINK}",
          },
          '2022' => {
            'count' => 2,
            'color' => 'gray',
            # city1 unclaimed 30/claimed 60, city2 unclaimed 40/claimed 50
            'code' => "city=revenue:30,loc:0;city=revenue:40,loc:3;#{MINE_LINK}",
          },
          '2023' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => 'city=revenue:0',
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
            # H10 also holds the Asteroid League's home token city. Its
            # `gray_0` (rather than omitting the gray key) is required --
            # a bare integer routes through Part::SingleRevenue instead of
            # MultiRevenue's off-board slot, colliding with that city part.
            %w[A13 D2 O11] => 'offboard=revenue:yellow_30|gray_60',
            %w[H18] => 'offboard=revenue:yellow_20|gray_70',
            %w[H10] => 'city=revenue:0;offboard=revenue:yellow_30|gray_0',
          },
          gray: { %w[A1 B6 D8 D14 F18 G7 H14 J2 J18 K9 M5 M13 O1] => 'city=revenue:0' },
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

        TRANSSHIPMENT_HEXES = %w[A13 D2 H10 O11 H18].freeze

        # Ordered to match the tile code's city= declarations.
        MINE_DATA = {
          '2001' => [{ ore: :n, unclaimed: 10, claimed: 50 }],
          '2002' => [{ ore: :n, unclaimed: 20, claimed: 60 }],
          '2003' => [{ ore: :i, unclaimed: 30, claimed: 40 }],
          '2004' => [{ ore: :i, unclaimed: 40, claimed: 50 }],
          '2005' => [{ ore: :i, unclaimed: 50, claimed: 60 }],
          '2006' => [{ ore: :r, unclaimed: 20, claimed: 50 }],
          '2007' => [{ ore: :r, unclaimed: 30, claimed: 60 }],
          '2008' => [{ ore: :r, unclaimed: 40, claimed: 70 }],
          '2009' => [{ ore: :n, unclaimed: 20, claimed: 60 }, { ore: :n, unclaimed: 10, claimed: 50 }],
          '2010' => [{ ore: :n, unclaimed: 20, claimed: 60 }, { ore: :n, unclaimed: 20, claimed: 60 }],
          '2011' => [{ ore: :i, unclaimed: 30, claimed: 40 }, { ore: :n, unclaimed: 10, claimed: 50 }],
          '2012' => [{ ore: :i, unclaimed: 30, claimed: 40 }, { ore: :n, unclaimed: 20, claimed: 60 }],
          '2013' => [{ ore: :i, unclaimed: 40, claimed: 50 }, { ore: :n, unclaimed: 10, claimed: 50 }],
          '2014' => [{ ore: :i, unclaimed: 40, claimed: 50 }, { ore: :n, unclaimed: 20, claimed: 60 }],
          '2015' => [{ ore: :r, unclaimed: 20, claimed: 50 }, { ore: :n, unclaimed: 10, claimed: 50 }],
          '2016' => [{ ore: :r, unclaimed: 20, claimed: 50 }, { ore: :n, unclaimed: 20, claimed: 60 }],
          '2017' => [{ ore: :r, unclaimed: 30, claimed: 60 }, { ore: :n, unclaimed: 10, claimed: 50 }],
          '2018' => [{ ore: :r, unclaimed: 30, claimed: 60 }, { ore: :n, unclaimed: 20, claimed: 60 }],
          '2019' => [{ ore: :r, unclaimed: 20, claimed: 50 }, { ore: :i, unclaimed: 30, claimed: 40 }],
          '2020' => [{ ore: :r, unclaimed: 20, claimed: 50 }, { ore: :i, unclaimed: 40, claimed: 50 }],
          '2021' => [{ ore: :r, unclaimed: 30, claimed: 60 }, { ore: :i, unclaimed: 30, claimed: 40 }],
          '2022' => [{ ore: :r, unclaimed: 30, claimed: 60 }, { ore: :i, unclaimed: 40, claimed: 50 }],
        }.freeze
      end
    end
  end
end
