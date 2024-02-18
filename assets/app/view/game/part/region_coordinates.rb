# frozen_string_literal: true

require 'lib/hex'
require 'view/game/part/base'

module View
  module Game
    module Part
      module RegionCoordinates
        RC_OFFSET = 7

        RC_ROWS = {
          0 => (Lib::Hex::Y_T * (3 / 4)),
          1 => (Lib::Hex::Y_T * (1 / 4)),
          2 => (Lib::Hex::Y_B * (1 / 4)),
          3 => (Lib::Hex::Y_B * (3 / 4)),
        }.freeze

        RC_COLS = {
          0 => (Lib::Hex::X_L * (3 / 4)),
          1 => (Lib::Hex::X_L * (2 / 4)),
          2 => (Lib::Hex::X_L * (1 / 4)),
          3 => 0,
          4 => (Lib::Hex::X_R * (1 / 4)),
          5 => (Lib::Hex::X_R * (2 / 4)),
          6 => (Lib::Hex::X_R * (3 / 4)),
        }.freeze

        REGION_CENTER_COORDINATES = {
          flat: {
            0 => { region_weights: [0], x: RC_COLS[1], y: RC_ROWS[0] + RC_OFFSET },
            1 => { region_weights: [1], x: RC_COLS[2], y: RC_ROWS[0] - RC_OFFSET },
            2 => { region_weights: [2], x: RC_COLS[3], y: RC_ROWS[0] + RC_OFFSET },
            3 => { region_weights: [3], x: RC_COLS[4], y: RC_ROWS[0] - RC_OFFSET },
            4 => { region_weights: [4], x: RC_COLS[5], y: RC_ROWS[0] + RC_OFFSET },
            5 => { region_weights: [5], x: RC_COLS[0], y: RC_ROWS[1] + RC_OFFSET },
            6 => { region_weights: [6], x: RC_COLS[1], y: RC_ROWS[1] - RC_OFFSET },
            7 => { region_weights: [7], x: RC_COLS[2], y: RC_ROWS[1] + RC_OFFSET },
            8 => { region_weights: [8], x: RC_COLS[3], y: RC_ROWS[1] - RC_OFFSET },
            9 => { region_weights: [9], x: RC_COLS[4], y: RC_ROWS[1] + RC_OFFSET },
            10 => { region_weights: [10], x: RC_COLS[5], y: RC_ROWS[1] - RC_OFFSET },
            11 => { region_weights: [11], x: RC_COLS[6], y: RC_ROWS[1] + RC_OFFSET },
            12 => { region_weights: [12], x: RC_COLS[0], y: RC_ROWS[2] - RC_OFFSET },
            13 => { region_weights: [13], x: RC_COLS[1], y: RC_ROWS[2] + RC_OFFSET },
            14 => { region_weights: [14], x: RC_COLS[2], y: RC_ROWS[2] - RC_OFFSET },
            15 => { region_weights: [15], x: RC_COLS[3], y: RC_ROWS[2] + RC_OFFSET },
            16 => { region_weights: [16], x: RC_COLS[4], y: RC_ROWS[2] - RC_OFFSET },
            17 => { region_weights: [17], x: RC_COLS[5], y: RC_ROWS[2] + RC_OFFSET },
            18 => { region_weights: [18], x: RC_COLS[6], y: RC_ROWS[2] - RC_OFFSET },
            19 => { region_weights: [19], x: RC_COLS[1], y: RC_ROWS[3] - RC_OFFSET },
            20 => { region_weights: [20], x: RC_COLS[2], y: RC_ROWS[3] + RC_OFFSET },
            21 => { region_weights: [21], x: RC_COLS[3], y: RC_ROWS[3] - RC_OFFSET },
            22 => { region_weights: [22], x: RC_COLS[4], y: RC_ROWS[3] + RC_OFFSET },
            23 => { region_weights: [23], x: RC_COLS[5], y: RC_ROWS[3] - RC_OFFSET },
          },
          pointy: {
            0 => { region_weights: [0], x: RC_ROWS[1] + RC_OFFSET, y: RC_COLS[0] },
            1 => { region_weights: [1], x: RC_ROWS[2] - RC_OFFSET, y: RC_COLS[0] },
            2 => { region_weights: [2], x: RC_ROWS[2] + RC_OFFSET, y: RC_COLS[1] },
            3 => { region_weights: [3], x: RC_ROWS[3] - RC_OFFSET, y: RC_COLS[1] },
            4 => { region_weights: [4], x: RC_ROWS[3] + RC_OFFSET, y: RC_COLS[2] },
            5 => { region_weights: [5], x: RC_ROWS[0] + RC_OFFSET, y: RC_COLS[1] },
            6 => { region_weights: [6], x: RC_ROWS[1] - RC_OFFSET, y: RC_COLS[1] },
            7 => { region_weights: [7], x: RC_ROWS[1] + RC_OFFSET, y: RC_COLS[2] },
            8 => { region_weights: [8], x: RC_ROWS[2] - RC_OFFSET, y: RC_COLS[2] },
            9 => { region_weights: [9], x: RC_ROWS[2] + RC_OFFSET, y: RC_COLS[3] },
            10 => { region_weights: [10], x: RC_ROWS[3] - RC_OFFSET, y: RC_COLS[3] },
            11 => { region_weights: [11], x: RC_ROWS[3] + RC_OFFSET, y: RC_COLS[4] },
            12 => { region_weights: [12], x: RC_ROWS[0] - RC_OFFSET, y: RC_COLS[2] },
            13 => { region_weights: [13], x: RC_ROWS[0] + RC_OFFSET, y: RC_COLS[3] },
            14 => { region_weights: [14], x: RC_ROWS[1] - RC_OFFSET, y: RC_COLS[3] },
            15 => { region_weights: [15], x: RC_ROWS[1] + RC_OFFSET, y: RC_COLS[4] },
            16 => { region_weights: [16], x: RC_ROWS[2] - RC_OFFSET, y: RC_COLS[4] },
            17 => { region_weights: [17], x: RC_ROWS[2] + RC_OFFSET, y: RC_COLS[5] },
            18 => { region_weights: [18], x: RC_ROWS[3] - RC_OFFSET, y: RC_COLS[5] },
            19 => { region_weights: [19], x: RC_ROWS[0] - RC_OFFSET, y: RC_COLS[4] },
            20 => { region_weights: [20], x: RC_ROWS[0] + RC_OFFSET, y: RC_COLS[5] },
            21 => { region_weights: [21], x: RC_ROWS[1] - RC_OFFSET, y: RC_COLS[5] },
            22 => { region_weights: [22], x: RC_ROWS[1] + RC_OFFSET, y: RC_COLS[6] },
            23 => { region_weights: [23], x: RC_ROWS[2] - RC_OFFSET, y: RC_COLS[6] },
          },
        }.freeze
      end
    end
  end
end
