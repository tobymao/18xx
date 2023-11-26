# frozen_string_literal: true

require_relative '../g_18_zoo/map'

module Engine
  module Game
    module G18ZOOMapE
      module Map
        include G18ZOO::Map

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

        BASE_2 = G18ZOO::Map::MAP_B_BASE_2

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
  end
end
