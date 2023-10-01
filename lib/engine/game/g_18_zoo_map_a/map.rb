# frozen_string_literal: true

require_relative '../g_18_zoo/map'

module Engine
  module Game
    module G18ZOOMapA
      module Map
        include G18ZOO::Map

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
  end
end
