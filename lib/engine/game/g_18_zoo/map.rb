# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module SharedMap
        TILE_Y = 'label=Y;city=revenue:yellow_30|green_40|brown_50,slots:1'
        TILE_O = 'town=revenue:10;label=O;icon=image:river,sticky:1'
        TILE_M = 'upgrade=cost:1,terrain:hill'
        TILE_MM = 'upgrade=cost:2,terrain:mountain'

        TILES = {
          '7' => 6,
          'X7' => {
            'count' => 6,
            'color' => 'yellow',
            'code' => "#{Engine::Config::Tile::YELLOW['3']};label=O;icon=image:river,sticky:1",
          },
          '8' => 16,
          'X8' => {
            'count' => 16,
            'color' => 'yellow',
            'code' => "#{Engine::Config::Tile::YELLOW['58']};label=O;icon=image:river,sticky:1",
          },
          '9' => 11,
          'X9' => {
            'count' => 11,
            'color' => 'yellow',
            'code' => "#{Engine::Config::Tile::YELLOW['4']};label=O;icon=image:river,sticky:1",
          },
          '5' => 2,
          '6' => 2,
          '57' => 2,
          '201' => 2,
          '202' => 2,
          '621' => 2,
          '19' => 1,
          'X19' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;path=a:2,b:_1;path=a:_1,b:4;'\
              'label=O;icon=image:river,sticky:1',
          },
          '23' => 2,
          'X23' => {
            'count' => 2,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['981']};label=O;icon=image:river,sticky:1",
          },
          '24' => 2,
          'X24' => {
            'count' => 2,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['991']};label=O;icon=image:river,sticky:1",
          },
          '25' => 2,
          'X25' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;path=a:0,b:_1;path=a:_1,b:4;'\
              'label=O;icon=image:river,sticky:1',
          },
          '26' => 2,
          'X26' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:3;path=a:0,b:_1;path=a:_1,b:5;'\
              'label=O;icon=image:river,sticky:1',
          },
          '27' => 2,
          'X27' => {
            'count' => 2,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:1;path=a:0,b:_1;path=a:_1,b:3;'\
              'label=O;icon=image:river,sticky:1',
          },
          '28' => 1,
          'X28' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:4;path=a:0,b:_1;path=a:_1,b:5;'\
              'label=O;icon=image:river,sticky:1',
          },
          '29' => 1,
          'X29' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:1;path=a:0,b:_1;path=a:_1,b:2;'\
              'label=O;icon=image:river,sticky:1',
          },
          '30' => 1,
          'X30' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:1;path=a:0,b:_1;path=a:_1,b:4;'\
              'label=O;icon=image:river,sticky:1',
          },
          '31' => 1,
          'X31' => {
            'count' => 1,
            'color' => 'green',
            'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:2;path=a:0,b:_1;path=a:_1,b:5;'\
              'label=O;icon=image:river,sticky:1',
          },
          '14' => 2,
          '15' => 2,
          '619' => 2,
          '576' => 1,
          '577' => 1,
          '579' => 1,
          '792' => 1,
          '793' => 1,
          '40' => 1,
          '41' => 1,
          '42' => 1,
          '43' => 1,
          '45' => 1,
          '46' => 1,
          '611' => 3,
          '582' => 3,
          'TI_455' => {
            'count' => 1,
            'color' => 'gray',
            'code' => "#{Engine::Config::Tile::GRAY['455']};icon=image:18_zoo/TI",
          },
          'GI_455' => {
            'count' => 1,
            'color' => 'gray',
            'code' => "#{Engine::Config::Tile::GRAY['455']};icon=image:18_zoo/GI",
          },
          'BB_455' => {
            'count' => 1,
            'color' => 'gray',
            'code' => "#{Engine::Config::Tile::GRAY['455']};icon=image:18_zoo/BB",
          },
          '80' => 1,
          'X80' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['143']};label=O;icon=image:river,sticky:1",
          },
          '81' => 1,
          'X81' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['144']};label=O;icon=image:river,sticky:1",
          },
          '82' => 1,
          'X82' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['141']};label=O;icon=image:river,sticky:1",
          },
          '83' => 1,
          'X83' => {
            'count' => 1,
            'color' => 'green',
            'code' => "#{Engine::Config::Tile::GREEN['142']};label=O;icon=image:river,sticky:1",
          },
        }.freeze

        def game_hole
          self.class::HOLE
        end

        def game_location_names
          self.class::LOCATION_NAMES
        end

        def game_base_2
          self.class::BASE_2
        end

        def game_location_name_base_2
          self.class::LOCATION_NAMES_BASE_2
        end

        def game_base_3
          self.class::BASE_3
        end

        def game_location_name_base_3
          self.class::LOCATION_NAMES_BASE_3
        end
      end

      module Map
        include G18ZOO::SharedMap
      end
    end

    module G18ZOOMapA
      module Map
        include G18ZOO::SharedMap

        HEXES = {
          gray: {
            %w[C9 D8 K5 M7 M13] => '',
            %w[N6 O7 P8 P10 O11 O13 O15 O17 O19 B8 C7 D6 H22 I21 L20 D18 E5 J20 M19 A9 A11 B16 A13 B18 F22 B14 F6 F20
               C19 G23 K21 N20 E19] => '',
            %w[N8] => 'path=a:0,b:1',
            %w[G9] => 'path=a:0,b:3',
            %w[I3] => 'path=a:0,b:4',
            %w[B10] => 'path=a:0,b:5',
            %w[L6] => 'path=a:1,b:3',
            %w[H20] => 'path=a:2,b:3',
            %w[K19] => 'path=a:2,b:4',
            %w[B12] => 'path=a:3,b:5',
            %w[H16] => 'path=a:1,b:4;path=a:3,b:5',
            %w[M15] => 'path=a:0,b:4;path=a:1,b:4',
            %w[K7] => 'path=a:0,b:4;path=a:4,b:5',
            %w[E7] => 'offboard=revenue:0,hide:1;path=a:0,b:_0',
            %w[M3 O9] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[J6 L10] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            %w[G21] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            %w[M9] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
            %w[L8] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            %w[I13] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            %w[M5 N18] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            %w[F8] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R',
            %w[C17] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            %w[I19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[J4 I5 G7 I7 H8 J8 D10 J10 G11 K11 M11 F12 H12 J12 L12 E13 G13 K13 D14 F14 C15 G15 D16 F16 J16 L16 I17
               M17 J18] => '',
            %w[K9 N10 K17 E15 H14] => 'city=revenue:0,slots:1',
            %w[C11 C13 F18 H10 I9 I11 J2 L14 N12 N14] => TILE_O,
            %w[D12 I15 J14 E17] => TILE_M,
            %w[E11 F10 G17 H18 K3 L18 N16] => TILE_MM,
            %w[E9 G19 K15 L4] => TILE_Y,
          },
        }.freeze

        HOLE = {
          'tiles' => {
            %w[B14 F6 F20 P8] => 'path=a:0,b:2,lanes:2',
            %w[A11 B16 O13 O15 O17] => 'path=a:0,b:3,lanes:2',
            %w[A9 O11] => 'path=a:0,b:4,lanes:2',
            %w[O19 P10] => 'path=a:1,b:3,lanes:2',
            %w[B8 C7 D6 H22 I21 L20] => 'path=a:1,b:4,lanes:2',
            %w[D18 E5 J20 M19] => 'path=a:1,b:5,lanes:2',
            %w[C19 G23 K21 N20] => 'path=a:2,b:4,lanes:2',
            %w[E19 N6 O7] => 'path=a:2,b:5,lanes:2',
            %w[A13 B18 F22] => 'path=a:3,b:5,lanes:2',
            %w[C17] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1',
            %w[F8] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R;'\
                        'path=a:3,b:4,a_lane:2.0;path=a:3,b:4,a_lane:2.1',
            %w[I19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1;',
            %w[M5] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R;'\
                        'path=a:5,b:2,a_lane:2.0;path=a:5,b:2,a_lane:2.1',
            %w[N18] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R;'\
                        'path=a:0,b:2,a_lane:2.0;path=a:0,b:2,a_lane:2.1',
          },
          'C17-F8-tiles' => %w[C17 B18 B16 B14 A13 A11 A9 B8 C7 D6 E5 F6 F8],
          'C17-F8' => {
            %w[C19] => 'path=a:2,b:3,lanes:2',
          },
          'C17-I19-tiles' => %w[C17 D18 E19 F20 F22 G23 H22 I19],
          'C17-I19' => {
            %w[C19] => 'path=a:4,b:3,lanes:2',
            %w[I21] => 'path=a:1,b:3,lanes:2',
          },
          'C17-M5-tiles' => %w[M5 N6 O7 P8 P10 O11 O13 O15 O17 O19 N20 M19 L20 K21 J20 I21 H22 G23 F22 F20 E19 D18
                               C17],
          'C17-M5' => {
            %w[C19] => 'path=a:4,b:3,lanes:2',
          },
          'C17-N18-tiles' => %w[N18 M19 L20 K21 J20 I21 H22 G23 F22 F20 E19 D18 C17],
          'C17-N18' => {
            %w[C19] => 'path=a:4,b:3,lanes:2',
            %w[N20] => 'path=a:2,b:3,lanes:2',
          },
          'F8-I19-tiles' => %w[I19 H22 G23 F22 F20 E19 D18 C19 B18 B16 B14 A13 A11 A9 B8 C7 D6 E5 F6 F8],
          'F8-I19' => {
            %w[I21] => 'path=a:1,b:3,lanes:2',
          },
          'F8-M5-tiles' => %w[M5 N6 O7 P8 P10 O11 O13 O15 O17 O19 N20 M19 L20 K21 J20 I21 H22 G23 F22 F20 E19 D18 C19
                              B18 B16 B14 A13 A11 A9 B8 C7 D6 E5 F6 F8],
          'F8-M5' => {},
          'F8-N18-tiles' => %w[N18 M19 L20 K21 J20 I21 H22 G23 F22 F20 E19 D18 C19 B18 B16 B14 A13 A11 A9 B8 C7 D6 E5
                               F6 F8],
          'F8-N18' => {
            %w[N20] => 'path=a:2,b:3,lanes:2',
          },
          'I19-M5-tiles' => %w[M5 N6 O7 P8 P10 O11 O13 O15 O17 O19 N20 M19 L20 K21 J20 I19],
          'I19-M5' => {
            %w[I21] => 'path=a:3,b:4,lanes:2',
          },
          'I19-N18-tiles' => %w[N18 M19 L20 K21 J20 I19],
          'I19-N18' => {
            %w[I21] => 'path=a:3,b:4,lanes:2',
            %w[N20] => 'path=a:2,b:3,lanes:2',
          },
          'M5-N18-tiles' => %w[M5 N6 O7 P8 P10 O11 O13 O15 O17 O19 N18],
          'M5-N18' => {
            %w[N20] => 'path=a:3,b:4,lanes:2',
          },
        }.freeze

        LOCATION_NAMES = {
          'E11' => 'MM',
          'F10' => 'MM',
          'G17' => 'MM',
          'H18' => 'MM',
          'K3' => 'MM',
          'L18' => 'MM',
          'N16' => 'MM',
          'D12' => 'M',
          'I15' => 'M',
          'J14' => 'M',
          'E17' => 'M',
        }.freeze

        BASE_2 = {
          'G7' => [TILE_O, :white],
          'G9' => [TILE_M, :white],
          'G11' => ['', :white],
          'H8' => [TILE_MM, :white],
          'H10' => ['offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
            'path=a:4,b:_0;path=a:5,b:_0;label=R', :red],
          'H12' => [TILE_M, :white],
          'I7' => [TILE_O, :white],
          'I9' => [TILE_M, :white],
          'I11' => ['', :white],
        }.freeze

        LOCATION_NAMES_BASE_2 = {
          'G9' => 'M',
          'H8' => 'MM',
          'H12' => 'M',
          'I9' => 'M',
        }.freeze

        BASE_3 = {
          'G7' => ['path=a:0,b:3', :gray],
          'G9' => [TILE_O, :white],
          'G11' => [TILE_MM, :white],
          'H8' => [TILE_MM, :white],
          'H10' => [TILE_Y, :white],
          'H12' => [TILE_O, :white],
          'I7' => ['path=a:2,b:3;path=a:1,b:3', :gray],
          'I9' => [TILE_O, :white],
          'I11' => [TILE_MM, :white],
        }.freeze

        LOCATION_NAMES_BASE_3 = {
          'G11' => 'MM',
          'H8' => 'MM',
          'I11' => 'MM',
        }.freeze
      end
    end

    module G18ZOOMapB
      module Map
        include G18ZOO::SharedMap

        HEXES = {
          gray: {
            %w[G14 M14 J21 K22 L21 M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7 M8] => '',
            %w[G4 I0 N9] => 'path=a:0,b:1',
            %w[G10] => 'path=a:0,b:3',
            %w[G0] => 'path=a:0,b:5',
            %w[I14] => 'path=a:1,b:4',
            %w[H21] => 'path=a:2,b:3',
            %w[K20] => 'path=a:2,b:4',
            %w[F5] => 'path=a:4,b:5',
            %w[M16] => 'path=a:0,b:4;path=a:1,b:4',
            %w[H17] => 'path=a:1,b:4;path=a:3,b:5',
            %w[K8] => 'path=a:0,b:4;path=a:4,b:5',
            %w[I4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[M4 O10] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[L11] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            %w[G22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            %w[L9] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            %w[M10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
          },
          red: {
            %w[M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            %w[N19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            %w[I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[F7 G8 G12 G18 H5 H7 H9 H13 H15 I2 I8 I18 J5 J7 J9 J11 J13 J17 J19 K12 K14 L13 L17 M12 M18] => '',
            %w[H3 I6 K10 K18 N11] => 'city=revenue:0,slots:1',
            %w[G2 G16 H1 H11 I10 I12 J3 L15 N13 N15] => TILE_O,
            %w[I16 J15 K6] => TILE_M,
            %w[H19 K4 L7 L19 N17] => TILE_MM,
            %w[G6 G20 K16 L5] => TILE_Y,
          },
        }.freeze

        HOLE = {
          'tiles' => {
            %w[J21 O8 N7] => 'path=a:2,b:5,lanes:2',
            %w[K22 N21] => 'path=a:2,b:4,lanes:2',
            %w[L21] => 'path=a:1,b:4,lanes:2',
            %w[M20] => 'path=a:1,b:5,lanes:2',
            %w[O20 P11] => 'path=a:1,b:3,lanes:2',
            %w[O18 O16 O14] => 'path=a:0,b:3,lanes:2',
            %w[O12] => 'path=a:0,b:4,lanes:2',
            %w[P9] => 'path=a:0,b:2,lanes:2',
            %w[M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R;'\
                          'path=a:1,b:5,b_lane:2.0;path=a:1,b:5,b_lane:2.1;'\
                          'path=a:2,b:5,b_lane:2.0;path=a:2,b:5,b_lane:2.1',
            %w[N19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R;'\
                          'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1',
            %w[I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                          'path=a:2,b:5,b_lane:2.0;path=a:2,b:5,b_lane:2.1;'\
                          'path=a:3,b:5,b_lane:2.0;path=a:3,b:5,b_lane:2.1;'\
                          'path=a:4,b:5,b_lane:2.0;path=a:4,b:5,b_lane:2.1;',
          },
          'I20-M6-tiles' => %w[I20 J21 K22 L21 M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7 M6],
          'I20-M6' => {},
          'I20-N19-tiles' => %w[I20 J21 K22 L21 M20 N19],
          'I20-N19' => {
            %w[N21] => 'path=a:2,b:3,lanes:2',
          },
          'M6-N19-tiles' => %w[N19 O20 O18 O16 O14 O12 P11 P9 O8 N7 M6],
          'M6-N19' => {
            %w[N21] => 'path=a:3,b:4,lanes:2',
          },
        }.freeze

        LOCATION_NAMES = {
          'I16' => 'M',
          'J15' => 'M',
          'K6' => 'M',
          'H19' => 'MM',
          'K4' => 'MM',
          'L7' => 'MM',
          'L19' => 'MM',
          'N17' => 'MM',
        }.freeze

        BASE_2 = {
          'G8' => [TILE_O, :white],
          'G10' => [TILE_M, :white],
          'G12' => ['', :white],
          'H9' => [TILE_MM, :white],
          'H11' => ['offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
            'path=a:4,b:_0;path=a:5,b:_0;label=R', :red],
          'H13' => [TILE_M, :white],
          'I8' => [TILE_O, :white],
          'I10' => [TILE_M, :white],
          'I12' => ['', :white],
        }.freeze

        LOCATION_NAMES_BASE_2 = {
          'G10' => 'M',
          'H9' => 'MM',
          'H13' => 'M',
          'I10' => 'M',
        }.freeze

        BASE_3 = {
          'G8' => ['path=a:0,b:3', :gray],
          'G10' => [TILE_O, :white],
          'G12' => [TILE_MM, :white],
          'H9' => [TILE_MM, :white],
          'H11' => [TILE_Y, :white],
          'H13' => [TILE_O, :white],
          'I8' => ['path=a:2,b:3;path=a:1,b:3', :gray],
          'I10' => [TILE_O, :white],
          'I12' => [TILE_MM, :white],
        }.freeze

        LOCATION_NAMES_BASE_3 = {
          'G12' => 'MM',
          'H9' => 'MM',
          'I12' => 'MM',
        }.freeze
      end
    end

    module G18ZOOMapC
      module Map
        include G18ZOO::SharedMap

        HEXES = {
          gray: {
            %w[G3 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D20 E19 F20 G21 G23] => '',
            %w[H24 I23 J22 K21 K19 K17 K15 K13 K11 K9 L8 M9 N8] => '',
            %w[E3 J0] => 'path=a:0,b:1',
            %w[G7] => 'path=a:1,b:4',
            %w[H10] => 'path=a:0,b:3',
            %w[H0] => 'path=a:0,b:5',
            %w[I21] => 'path=a:2,b:3',
            %w[C13] => 'path=a:3,b:5',
            %w[D4] => 'path=a:4,b:5',
            %w[I17] => 'path=a:1,b:4;path=a:3,b:5',
            %w[J4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[B10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0',
            %w[N4] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[H22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            %w[J14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            %w[N6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            %w[F2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R',
            %w[D18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            %w[J20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;label=R',
          },
          white: {
            %w[D10 D16 E11 E15 E17 F4 F14 G5 G13 G15 G17 H4 H8 H12 H14 H16 I5 I7 I9 I13 J2 J8 J18 K5 K7] => '',
            %w[E5 F16 I3 I15 J6] => 'city=revenue:0,slots:1',
            %w[D12 D14 E9 F6 G19 H2 I1 I11 J10 J12 K3] => TILE_O,
            %w[E13 F18 G9 J16 L6] => TILE_M,
            %w[E7 F8 F12 G11 H18 I19 L4 M7] => TILE_MM,
            %w[C11 F10 H6 H20 M5] => TILE_Y,
          },
        }.freeze

        HOLE = {
          'tiles' => {
            %w[E1 B8 E19 L8] => 'path=a:1,b:5,lanes:2',
            %w[D2 I23 J22] => 'path=a:1,b:4,lanes:2',
            %w[C3 A9 K9] => 'path=a:0,b:4,lanes:2',
            %w[C5 A11 B14 C19 G23] => 'path=a:3,b:5,lanes:2',
            %w[D6 B12 C15 G21] => 'path=a:0,b:2,lanes:2',
            %w[D8 K21 N8] => 'path=a:1,b:3,lanes:2',
            %w[C9 D20 H24 M9] => 'path=a:2,b:4,lanes:2',
            %w[C17 K19 K17 K15 K13 K11] => 'path=a:0,b:3,lanes:2',
            %w[F20] => 'path=a:2,b:5,lanes:2',
            %w[N6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R;'\
                        'path=a:1,b:0,b_lane:2.0;path=a:1,b:0,b_lane:2.1;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1',
            %w[F2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R;'\
                        'path=a:0,b:2,b_lane:2.0;path=a:0,b:2,b_lane:2.1',
            %w[D18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1',
            %w[J20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;label=R;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1',
          },
          'D18-F2-tiles' => %w[F2 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D18],
          'D18-F2' => {
            %w[D20] => 'path=a:2,b:3,lanes:2',
          },
          'D18-J20-tiles' => %w[D18 E19 F20 G21 G23 H24 I23 J20],
          'D18-J20' => {
            %w[D20] => 'path=a:3,b:4,lanes:2',
            %w[J22] => 'path=a:1,b:3,lanes:2',
          },
          'D18-N6-tiles' => %w[D18 E19 F20 G21 G23 H24 I23 J22 K21 K19 K17 K15 K13 K11 K9 L8 M9 N8 N6],
          'D18-N6' => {
            %w[D20] => 'path=a:3,b:4,lanes:2',
          },
          'F2-J20-tiles' => %w[F2 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D20 E19 F20 G21 G23 H24 I23 J20],
          'F2-J20' => {
            %w[J22] => 'path=a:1,b:3,lanes:2',
          },
          'F2-N6-tiles' => %w[F2 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D20 E19 F20 G21 G23 H24 I23 J22
                              K21 K19 K17 K15 K13 K11 K9 L8 M9 N8 N6],
          'F2-N6' => {},
          'J20-N6-tiles' => %w[J20 K21 K19 K17 K15 K13 K11 K9 L8 M9 N8 N6],
          'J20-N6' => {
            %w[J22] => 'path=a:3,b:4,lanes:2',
          },
        }.freeze

        LOCATION_NAMES = {
          'E13' => 'M',
          'F18' => 'M',
          'G9' => 'M',
          'J16' => 'M',
          'L6' => 'M',
          'E7' => 'MM',
          'F8' => 'MM',
          'F12' => 'MM',
          'G11' => 'MM',
          'H18' => 'MM',
          'I19' => 'MM',
          'L4' => 'MM',
          'M7' => 'MM',
        }.freeze

        BASE_2 = {
          'G7' => [TILE_O, :white],
          'G9' => [TILE_M, :white],
          'G11' => ['', :white],
          'H8' => [TILE_MM, :white],
          'H10' => ['offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
            'path=a:4,b:_0;path=a:5,b:_0;label=R', :red],
          'H12' => [TILE_M, :white],
          'I7' => [TILE_O, :white],
          'I9' => [TILE_M, :white],
          'I11' => ['', :white],
        }.freeze

        LOCATION_NAMES_BASE_2 = {
          'G9' => 'M',
          'G11' => nil,
          'H8' => 'MM',
          'H12' => 'M',
          'I9' => 'M',
        }.freeze

        BASE_3 = {
          'G7' => ['path=a:0,b:3', :gray],
          'G9' => [TILE_O, :white],
          'G11' => [TILE_MM, :white],
          'H8' => [TILE_MM, :white],
          'H10' => [TILE_Y, :white],
          'H12' => [TILE_O, :white],
          'I7' => ['path=a:2,b:3;path=a:1,b:3', :gray],
          'I9' => [TILE_O, :white],
          'I11' => [TILE_MM, :white],
        }.freeze

        LOCATION_NAMES_BASE_3 = {
          'G9' => nil,
          'G11' => 'MM',
          'H8' => 'MM',
          'I11' => 'MM',
        }.freeze
      end
    end

    module G18ZOOMapD
      module Map
        include G18ZOO::SharedMap

        HEXES = {
          gray: {
            %w[C10 D9 E6 M14 D7 C8 B9 A10 A12 A14 B15 B17 B19 C20 D19 E20 F21 F23] => '',
            %w[G24 H23 I22 J21 K22 L21 M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7 M8] => '',
            %w[G4 I0 N9] => 'path=a:0,b:1',
            %w[G10] => 'path=a:0,b:3',
            %w[B11 G0] => 'path=a:0,b:5',
            %w[H21] => 'path=a:2,b:3',
            %w[K20] => 'path=a:2,b:4',
            %w[B13] => 'path=a:3,b:5',
            %w[F5] => 'path=a:4,b:5',
            %w[M16] => 'path=a:0,b:4;path=a:1,b:4',
            %w[H17] => 'path=a:1,b:4;path=a:3,b:5',
            %w[K8] => 'path=a:0,b:4;path=a:4,b:5',
            %w[I4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[M4 O10] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[E8] => 'offboard=revenue:0,hide:1;path=a:0,b:_0',
            %w[L11] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            %w[G22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            %w[L9] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            %w[M10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
            %w[I14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            %w[M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            %w[N19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            %w[F9] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R',
            %w[C18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            %w[I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[C16 D11 D15 D17 E14 F7 F13 F15 F17 G8 G12 G14 G16 H5 H7 H9 H13 I2 I8 I18 J5 J7 J9 J11 J13 J17 J19 K12
               K14 L13 L17 M12 M18] => '',
            %w[E16 H3 H15 I6 K10 K18 N11] => 'city=revenue:0,slots:1',
            %w[C12 C14 F19 G2 H1 H11 I10 I12 J3 L15 N13 N15] => TILE_O,
            %w[D13 E18 I16 J15 K6] => TILE_M,
            %w[E12 F11 G18 H19 K4 L7 L19 N17] => TILE_MM,
            %w[E10 G6 G20 K16 L5] => TILE_Y,
          },
        }.freeze

        HOLE = {
          'tiles' => {
            %w[E20 O8 N7] => 'path=a:2,b:5,lanes:2',
            %w[C20 G24 K22 N21] => 'path=a:2,b:4,lanes:2',
            %w[C8 B9 H23 I22 L21] => 'path=a:1,b:4,lanes:2',
            %w[D7 D19 J21 M20] => 'path=a:1,b:5,lanes:2',
            %w[O20 P11] => 'path=a:1,b:3,lanes:2',
            %w[B15 F21 P9] => 'path=a:0,b:2,lanes:2',
            %w[A12 B17 O18 O16 O14] => 'path=a:0,b:3,lanes:2',
            %w[A10 O12] => 'path=a:0,b:4,lanes:2',
            %w[A14 B19 F23] => 'path=a:3,b:5,lanes:2',
            %w[E8] => 'offboard=revenue:0,hide:1;path=a:0,b:_0;path=a:2,b:5,lanes:2',
            %w[M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R;'\
                        'path=a:1,b:5,b_lane:2.0;path=a:1,b:5,b_lane:2.1;'\
                        'path=a:2,b:5,b_lane:2.0;path=a:2,b:5,b_lane:2.1',
            %w[N19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1',
            %w[F9] => 'offboard=revenue:yellow_30|brown_60;path=a:4,b:_0;label=R;'\
                        'path=a:4,b:2,b_lane:2.0;path=a:4,b:2,b_lane:2.1',
            %w[C18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1',
            %w[I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1',
          },
          'C18-F9-tiles' => %w[F9 E8 D7 C8 B9 A10 A12 A14 B15 B17 B19 C18],
          'C18-F9' => {
            %w[C20] => 'path=a:2,b:3,lanes:2',
          },
          'C18-I20-tiles' => %w[C18 D19 E20 F21 F23 G24 H23 I20],
          'C18-I20' => {
            %w[C20] => 'path=a:3,b:4,lanes:2',
            %w[I22] => 'path=a:1,b:3,lanes:2',
          },
          'C18-M6-tiles' => %w[C18 D19 E20 F21 F23 G24 H23 I22 J21 K22 L21 M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7
                               M8 M6],
          'C18-M6' => {
            %w[C20] => 'path=a:3,b:4,lanes:2',
          },
          'C18-N19-tiles' => %w[C18 D19 E20 F21 F23 G24 H23 I22 J21 K22 L21 M20 N19],
          'C18-N19' => {
            %w[C20] => 'path=a:3,b:4,lanes:2',
            %w[N21] => 'path=a:2,b:3,lanes:2',
          },
          'F9-I20-tiles' => %w[F9 E8 D7 C8 B9 A10 A12 A14 B15 B17 B19 C20 D19 E20 F21 F23 G24 H23 I20],
          'F9-I20' => {
            %w[I22] => 'path=a:1,b:3,lanes:2',
          },
          'F9-M6-tiles' => %w[F9 E8 D7 C8 B9 A10 A12 A14 B15 B17 B19 C20 D19 E20 F21 F23 G24 H23 I22 J21 K22 L21 M20
                              N21 O20 O18 O16 O14 O12 P11 P9 O8 N7 M8 M6],
          'F9-M6' => {},
          'F9-N19-tiles' => %w[F9 E8 D7 C8 B9 A10 A12 A14 B15 B17 B19 C20 D19 E20 F21 F23 G24 H23 I22 J21 K22 L21 M20
                               N19],
          'F9-N19' => {
            %w[N21] => 'path=a:2,b:3,lanes:2',
          },
          'I20-M6-tiles' => %w[I20 J21 K22 L21 M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7 M8 M6],
          'I20-M6' => {
            %w[I22] => 'path=a:3,b:4,lanes:2',
          },
          'I20-N19-tiles' => %w[I20 J21 K22 L21 M20 N19],
          'I20-N19' => {
            %w[I22] => 'path=a:3,b:4,lanes:2',
            %w[N21] => 'path=a:2,b:3,lanes:2',
          },
          'M6-N19-tiles' => %w[N19 O20 O18 O16 O14 O12 P11 P9 O8 N7 M8 M6],
          'M6-N19' => {
            %w[N21] => 'path=a:3,b:4,lanes:2',
          },
        }.freeze

        LOCATION_NAMES = {
          'D13' => 'M',
          'E18' => 'M',
          'I16' => 'M',
          'J15' => 'M',
          'K6' => 'M',
          'E12' => 'MM',
          'F11' => 'MM',
          'G18' => 'MM',
          'H19' => 'MM',
          'K4' => 'MM',
          'L7' => 'MM',
          'L19' => 'MM',
          'N17' => 'MM',
        }.freeze

        BASE_2 = G18ZOOMapB::Map::BASE_2

        LOCATION_NAMES_BASE_2 = {
          'G10' => 'M',
          'H9' => 'MM',
          'H13' => 'M',
          'I10' => 'M',
        }.freeze

        BASE_3 = {
          'G8' => ['path=a:0,b:3', :gray],
          'G10' => [TILE_O, :white],
          'G12' => [TILE_MM, :white],
          'H9' => [TILE_MM, :white],
          'H11' => [TILE_Y, :white],
          'H13' => [TILE_O, :white],
          'I8' => ['path=a:2,b:3;path=a:1,b:3', :gray],
          'I10' => [TILE_O, :white],
          'I12' => [TILE_MM, :white],
        }.freeze

        LOCATION_NAMES_BASE_3 = {
          'G12' => 'MM',
          'H9' => 'MM',
          'I12' => 'MM',
        }.freeze
      end
    end

    module G18ZOOMapE
      module Map
        include G18ZOO::SharedMap

        HEXES = {
          gray: {
            %w[F3 F15 M8 M14 D1 C2 B3 B5 C6 C8 D9 E8 F9 F11 F13 E14 E16 E18 E20] => '',
            %w[F21 F23 G24 H23 I22 J21 K22 L21 M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7] => '',
            %w[D3 I0 N9] => 'path=a:0,b:1',
            %w[G10] => 'path=a:0,b:3',
            %w[G0] => 'path=a:0,b:5',
            %w[H21] => 'path=a:2,b:3',
            %w[K20] => 'path=a:2,b:4',
            %w[M16] => 'path=a:0,b:4;path=a:1,b:4',
            %w[C4] => 'path=a:4,b:5',
            %w[H17] => 'path=a:1,b:4;path=a:3,b:5',
            %w[K8] => 'path=a:0,b:4;path=a:4,b:5',
            %w[I4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[M4 O10] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[L11] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            %w[G22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            %w[F7] => 'offboard=revenue:0,hide:1;path=a:4,b:_0',
            %w[L9] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:2,b:5',
            %w[M10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0;path=a:2,b:4',
            %w[I14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            %w[M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            %w[N19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R',
            %w[E2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R',
            %w[I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[E4 F5 G4 G8 G12 G14 G16 H5 H7 H9 H13 I2 I8 I18 J5 J7 J9 J11 J13 J17 J19 K12 K14 L13 L17 M12 M18] => '',
            %w[D5 H3 H15 I6 K10 K18 N11] => 'city=revenue:0,slots:1',
            %w[E6 F17 F19 G2 H1 H11 I10 I12 J3 L15 N13 N15] => TILE_O,
            %w[I16 J15 K6] => TILE_M,
            %w[D7 G18 H19 K4 L7 L19 N17] => TILE_MM,
            %w[G6 G20 K16 L5] => TILE_Y,
          },
        }.freeze

        HOLE = {
          'tiles' => {
            %w[D1 E8 J21 M20] => 'path=a:1,b:5,lanes:2',
            %w[C2 H23 I22 L21] => 'path=a:1,b:4,lanes:2',
            %w[O20] => 'path=a:1,b:3,lanes:2',
            %w[B3 E14 O12] => 'path=a:0,b:4,lanes:2',
            %w[B5 C8 E20 F23] => 'path=a:3,b:5,lanes:2',
            %w[C6 F9 F21 P9] => 'path=a:0,b:2,lanes:2',
            %w[F13 P11] => 'path=a:1,b:3,lanes:2',
            %w[D9 G24 K22 N21] => 'path=a:2,b:4,lanes:2',
            %w[F11 E16 E18 O18 O16 O14] => 'path=a:0,b:3,lanes:2',
            %w[O8 N7] => 'path=a:2,b:5,lanes:2',
            %w[M6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R;'\
                        'path=a:1,b:5,b_lane:2.0;path=a:1,b:5,b_lane:2.1;'\
                        'path=a:2,b:5,b_lane:2.0;path=a:2,b:5,b_lane:2.1',
            %w[N19] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;label=R;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1',
            %w[E2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R;'\
                        'path=a:0,b:2,b_lane:2.0;path=a:0,b:2,b_lane:2.1',
            %w[I20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1',
          },
          'E2-I20-tiles' => %w[E2 D1 C2 B3 B5 C6 C8 D9 E8 F9 F11 F13 E14 E16 E18 E20 F21 F23 G24 H23 I20],
          'E2-I20' => {
            %w[I22] => 'path=a:1,b:3,lanes:2',
          },
          'E2-M6-tiles' => %w[E2 D1 C2 B3 B5 C6 C8 D9 E8 F9 F11 F13 E14 E16 E18 E20 F21 F23 G24 H23 I22 J21 K22 L21
                              M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7 M6],
          'E2-M6' => {},
          'E2-N19-tiles' => %w[E2 D1 C2 B3 B5 C6 C8 D9 E8 F9 F11 F13 E14 E16 E18 E20 F21 F23 G24 H23 I22 J21 K22 L21
                               M20 N19],
          'E2-N19' => {
            %w[N21] => 'path=a:2,b:3,lanes:2',
          },
          'I20-M6-tiles' => %w[I20 J21 K22 L21 M20 N21 O20 O18 O16 O14 O12 P11 P9 O8 N7 M6],
          'I20-M6' => {
            %w[I22] => 'path=a:3,b:4,lanes:2',
          },
          'I20-N19-tiles' => %w[I20 J21 K22 L21 M20 N19],
          'I20-N19' => {
            %w[I22] => 'path=a:3,b:4,lanes:2',
            %w[N21] => 'path=a:2,b:3,lanes:2',
          },
          'M6-N19-tiles' => %w[N19 O20 O18 O16 O14 O12 P11 P9 O8 N7 M6],
          'M6-N19' => {
            %w[N21] => 'path=a:3,b:4,lanes:2',
          },
        }.freeze

        LOCATION_NAMES = {
          'I16' => 'M',
          'J15' => 'M',
          'K6' => 'M',
          'D7' => 'MM',
          'G18' => 'MM',
          'H19' => 'MM',
          'K4' => 'MM',
          'L7' => 'MM',
          'L19' => 'MM',
          'N17' => 'MM',
        }.freeze

        BASE_2 = G18ZOOMapB::Map::BASE_2

        LOCATION_NAMES_BASE_2 = {
          'G10' => 'M',
          'H9' => 'MM',
          'H13' => 'M',
          'I10' => 'M',
        }.freeze

        BASE_3 = {
          'G8' => ['path=a:0,b:3', :gray],
          'G10' => [TILE_O, :white],
          'G12' => [TILE_MM, :white],
          'H9' => [TILE_MM, :white],
          'H11' => [TILE_Y, :white],
          'H13' => [TILE_O, :white],
          'I8' => ['path=a:2,b:3;path=a:1,b:3', :gray],
          'I10' => [TILE_O, :white],
          'I12' => [TILE_MM, :white],
        }.freeze

        LOCATION_NAMES_BASE_3 = {
          'G12' => 'MM',
          'H9' => 'MM',
          'I12' => 'MM',
        }.freeze
      end
    end

    module G18ZOOMapF
      module Map
        include G18ZOO::SharedMap

        HEXES = {
          gray: {
            %w[G3 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D20 E19 F20 G21 G23 H24 I23 J22 K21 L20 M21 N20
               N18 N16 N14 N12 N10 N8] => '',
            %w[E3 J0] => 'path=a:0,b:1',
            %w[M11] => 'path=a:0,b:2;path=a:0,b:3',
            %w[H10 M13] => 'path=a:0,b:3',
            %w[H0 K15] => 'path=a:0,b:5',
            %w[L12] => 'path=a:1,b:3',
            %w[G7] => 'path=a:1,b:4',
            %w[K13] => 'path=a:1,b:4',
            %w[I21] => 'path=a:2,b:3',
            %w[C13] => 'path=a:3,b:5',
            %w[D4] => 'path=a:4,b:5',
            %w[I17] => 'path=a:1,b:4;path=a:3,b:5',
            %w[J4] => 'junction;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
            %w[N4] => 'offboard=revenue:0,hide:1;path=a:1,b:_0',
            %w[M19] => 'offboard=revenue:0,hide:1;path=a:2,b:_0',
            %w[H22] => 'offboard=revenue:0,hide:1;path=a:3,b:_0',
            %w[K11] => 'offboard=revenue:0,hide:1;path=a:4,b:_0',
            %w[B10] => 'offboard=revenue:0,hide:1;path=a:5,b:_0',
            %w[M9] => 'offboard=revenue:0,hide:1;path=a:1,b:2;path=a:2,b:0',
            %w[J14] => 'offboard=revenue:0,hide:1;path=a:1,b:_0;path=a:0,b:4',
          },
          red: {
            %w[N6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R',
            %w[F2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R',
            %w[D18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R',
            %w[J20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R',
          },
          white: {
            %w[D10 D16 E11 E15 E17 F4 F14 G5 G13 G15 G17 H4 H8 H12 H14 H16 I5 I7 I9 I13 J2 J8 J18 K5 K7 K9 K17 K19 L8
               L14] => '',
            %w[E5 F16 I3 I15 J6 L10 L18] => 'city=revenue:0,slots:1',
            %w[D12 D14 E9 F6 G19 H2 I1 I11 J10 J12 K3 M15 M17] => TILE_O,
            %w[E13 F18 G9 J16 L6] => TILE_M,
            %w[E7 F8 F12 G11 H18 I19 L4 M7] => TILE_MM,
            %w[C11 F10 H6 H20 L16 M5] => TILE_Y,
          },
        }.freeze

        HOLE = {
          'tiles' => {
            %w[E1 B8 E19 L20] => 'path=a:1,b:5,lanes:2',
            %w[D2 I23 J22 K21] => 'path=a:1,b:4,lanes:2',
            %w[N20] => 'path=a:1,b:3,lanes:2',
            %w[C3 A9] => 'path=a:0,b:4,lanes:2',
            %w[C5 A11 B14 C19 G23] => 'path=a:3,b:5,lanes:2',
            %w[D6 B12 C15 G21] => 'path=a:0,b:2,lanes:2',
            %w[D8 A13] => 'path=a:1,b:3,lanes:2',
            %w[C9 D20 H24 I22 M21] => 'path=a:2,b:4,lanes:2',
            %w[C17 N18 N16 N14 N12 N10 N8] => 'path=a:0,b:3,lanes:2',
            %w[F20] => 'path=a:2,b:5,lanes:2',
            %w[N6] => 'offboard=revenue:yellow_30|brown_60;path=a:1,b:_0;path=a:2,b:_0;label=R;'\
                        'path=a:1,b:0,b_lane:2.0;path=a:1,b:0,b_lane:2.1;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1',
            %w[F2] => 'offboard=revenue:yellow_30|brown_60;path=a:0,b:_0;label=R;'\
                        'path=a:0,b:2,b_lane:2.0;path=a:0,b:2,b_lane:2.1',
            %w[D18] => 'offboard=revenue:yellow_30|brown_60;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1',
            %w[J20] => 'offboard=revenue:yellow_30|brown_60;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;label=R;'\
                        'path=a:2,b:0,b_lane:2.0;path=a:2,b:0,b_lane:2.1;'\
                        'path=a:3,b:0,b_lane:2.0;path=a:3,b:0,b_lane:2.1;'\
                        'path=a:4,b:0,b_lane:2.0;path=a:4,b:0,b_lane:2.1',
          },
          'D18-F2-tiles' => %w[F2 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D18],
          'D18-F2' => {
            %w[D20] => 'path=a:2,b:3,lanes:2',
          },
          'D18-J20-tiles' => %w[D18 E19 F20 G21 G23 H24 I23 J20],
          'D18-J20' => {
            %w[D20] => 'path=a:3,b:4,lanes:2',
            %w[J22] => 'path=a:1,b:3,lanes:2',
          },
          'D18-N6-tiles' => %w[D18 E19 F20 G21 G23 H24 I23 J22 K21 L20 M21 N20 N18 N16 N14 N12 N10 N8 N6],
          'D18-N6' => {
            %w[D20] => 'path=a:3,b:4,lanes:2',
          },
          'F2-J20-tiles' => %w[F2 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D20 E19 F20 G21 G23 H24 I23 J20],
          'F2-J20' => {
            %w[J22] => 'path=a:1,b:3,lanes:2',
          },
          'F2-N6-tiles' => %w[F2 E1 D2 C3 C5 D6 D8 C9 B8 A9 A11 B12 B14 C15 C17 C19 D20 E19 F20 G21 G23 H24 I23 J22
                              K21 L20 M21 N20 N18 N16 N14 N12 N10 N8 N6],
          'F2-N6' => {
          },
          'J20-N6-tiles' => %w[J20 K21 L20 M21 N20 N18 N16 N14 N12 N10 N8 N6],
          'J20-N6' => {
            %w[J22] => 'path=a:3,b:4,lanes:2',
          },
        }.freeze

        LOCATION_NAMES = G18ZOOMapC::Map::LOCATION_NAMES

        BASE_2 = G18ZOOMapC::Map::BASE_2

        LOCATION_NAMES_BASE_2 = {
          'G9' => 'M',
          'G11' => nil,
          'H8' => 'MM',
          'H12' => 'M',
          'I9' => 'M',
        }.freeze

        BASE_3 = {
          'G7' => ['path=a:0,b:3', :gray],
          'G9' => [TILE_O, :white],
          'G11' => [TILE_MM, :white],
          'H8' => [TILE_MM, :white],
          'H10' => [TILE_Y, :white],
          'H12' => [TILE_O, :white],
          'I7' => ['path=a:2,b:3;path=a:1,b:3', :gray],
          'I9' => [TILE_O, :white],
          'I11' => [TILE_MM, :white],
        }.freeze

        LOCATION_NAMES_BASE_3 = {
          'G9' => nil,
          'G11' => 'MM',
          'H8' => 'MM',
          'I11' => 'MM',
        }.freeze
      end
    end
  end
end
