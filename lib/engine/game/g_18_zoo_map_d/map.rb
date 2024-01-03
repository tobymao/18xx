# frozen_string_literal: true

require_relative '../g_18_zoo/map'

module Engine
  module Game
    module G18ZOOMapD
      module Map
        include G18ZOO::Map

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
