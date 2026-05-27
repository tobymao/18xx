# frozen_string_literal: true

module Engine
  module Game
    module G2038
      module Map
        # Shared path segments for tile code strings.
        # SP6: all 6 edges - junction(_0) + city(_1); used by single-mine tiles.
        # DP6: all 6 edges - junction(_0) + city1(_1) + city2(_2); used by double-mine tiles.
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
            'count' => 40,
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
      end
    end
  end
end
