# frozen_string_literal: true

require_relative '../g_18_zoo/map'

module Engine
  module Game
    module G18ZOOMapF
      module Map
        include G18ZOO::Map

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

        LOCATION_NAMES = G18ZOO::Map::MAP_C_LOCATION_NAMES

        BASE_2 = G18ZOO::Map::MAP_C_BASE_2

        LOCATION_NAMES_BASE_2 = {
          'H10' => 'M',
          'I9' => 'MM',
          'I13' => 'M',
          'J10' => 'M',
        }.freeze

        BASE_3 = {
          'H8' => ['path=a:0,b:3', :gray],
          'H10' => [TILE_O, :white],
          'H12' => [TILE_MM, :white],
          'I9' => [TILE_MM, :white],
          'I11' => [TILE_Y, :white],
          'I13' => [TILE_O, :white],
          'J8' => ['path=a:2,b:3;path=a:1,b:3', :gray],
          'J10' => [TILE_O, :white],
          'J12' => [TILE_MM, :white],
        }.freeze

        LOCATION_NAMES_BASE_3 = {
          'H12' => 'MM',
          'I9' => 'MM',
          'J12' => 'MM',
        }.freeze
      end
    end
  end
end
