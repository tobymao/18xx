# frozen_string_literal: true

module Engine
  module Game
    module G2038
      module Map
        # Our tiles carry no functional track: hex-to-hex adjacency is purely
        # geometric (`Game::Base#connect_hexes` builds `hex.neighbors` from
        # grid coordinates alone; see `Game#hexes_in_range`/`Step::Route`,
        # which never inspect a tile's paths). A single-city tile centers
        # itself automatically with no path at all (`Tile#compute_city_town_edges`).
        #
        # The one exception: a double-mine tile's two cities need a cosmetic-
        # only link between them (no edge connection) so each city's `loc:`
        # -- and therefore the random rotation `Game#explore_hex!` applies for
        # visual variety -- is actually respected. Without any path at all,
        # the engine's default path-less-multi-city placement kicks in
        # instead, which ignores rotation entirely.
        MINE_LINK = 'path=a:_0,b:_1,track:thin'

        # Note that many elements here have defined color attributes, but those
        # attributes are not actually displayed on the screen.  Instead, we have
        # custom rendering logic in /18xx/assets/app/view/game/hex_g2038.rb which
        # renders the custom starfield and icon images used in this game.

        # Mine city revenue: displayed value is the UNCLAIMED value; the claimed
        # value (paid only to the claim owner) lives in MINE_DATA and is applied
        # by the pickup logic, not by the tile.
        TILES = {
          # Single-mine N tiles
          '2001' => {
            'count' => 12,
            'color' => 'gray',
            # unclaimed 10 / claimed 50
            'code' => "city=revenue:10",
          },
          '2002' => {
            'count' => 12,
            'color' => 'gray',
            # unclaimed 20 / claimed 60
            'code' => "city=revenue:20",
          },
          # Single-mine I tiles
          '2003' => {
            'count' => 2,
            'color' => 'gray',
            # unclaimed 30 / claimed 40
            'code' => "city=revenue:30",
          },
          '2004' => {
            'count' => 4,
            'color' => 'gray',
            # unclaimed 40 / claimed 50
            'code' => "city=revenue:40",
          },
          '2005' => {
            'count' => 8,
            'color' => 'gray',
            # unclaimed 50 / claimed 60
            'code' => "city=revenue:50",
          },
          # Single-mine R tiles
          '2006' => {
            'count' => 2,
            'color' => 'gray',
            # unclaimed 20 / claimed 50
            'code' => "city=revenue:20",
          },
          '2007' => {
            'count' => 4,
            'color' => 'gray',
            # unclaimed 30 / claimed 60
            'code' => "city=revenue:30",
          },
          '2008' => {
            'count' => 6,
            'color' => 'gray',
            # unclaimed 40 / claimed 70
            'code' => "city=revenue:40",
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
          # Gray base tile - placed when a corporation establishes a base on an explored asteroid.
          # The city slot holds the base token; revenue is tracked via corporation base mechanics.
          '2023' => {
            'count' => 'unlimited',
            'color' => 'gray',
            'code' => "city=revenue:0",
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
            # Transshipment points -- phase-scaled dual-value revenue
            # (§8: A13/D2/O11 go $30 -> $60, H18 goes $20 -> $70 once gray
            # tiles unlock) rendered as a standard off-board box, one
            # colored box per phase value, same convention every other
            # 18xx game uses for red off-board areas -- rather than a
            # single mine-style circle showing only the current value.
            # H10 also doubles as the Asteroid League's home hex, so it
            # keeps its own zero-revenue city (for AL's home token) on the
            # same hex, alongside the offboard part that actually carries
            # the transshipment value; the other four have no city at all.
            # H10 pays a flat $30 that drops to $0 once gray tiles unlock
            # at Phase 4.

            # The AL is always formed by Phase 4 (asteroid_league_must_form is a
            # Phase 4 event), and its own base replaces this transshipment
            # point the moment AL forms (Game#transshipment_hex?'s
            # existing @asteroid_league_formed check already stops paying
            # it out in the revenue logic regardless of what the tile
            # displays). Ideally this would show no gray box at all rather than a $0 one, but
            # a bare integer (no phase-color key at all) renders through a
            # different view component (Part::SingleRevenue, generic
            # small-item placement) instead of Part::MultiRevenue's
            # dedicated off-board box position, which collided with (and
            # rendered behind) H10's own city part for AL's home token --
            # found live in browser as the $30 box vanishing entirely. A
            # zero-value gray key keeps the working MultiRevenue rendering
            # path while still being accurate (nothing is ever actually
            # paid there once gray phase arrives).
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

        # Gray hexes that serve as delivery destinations (transshipment points).
        TRANSSHIPMENT_HEXES = %w[A13 D2 H10 O11 H18].freeze

        # Maps each asteroid tile number to its mine definitions.
        # Each entry is an array of hashes (one per mine), ordered to match
        # the city= declarations in the tile code (city 0, city 1, ...).
        # `claimed:` is data for the claims feature (bases/refueling/claims
        # infrastructure), not yet implemented in this PR -- it's defined
        # here alongside `unclaimed:` now rather than added piecemeal later,
        # since both values are fixed game data from the same rules table,
        # but nothing reads `claimed:` until that follow-up PR lands.
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
