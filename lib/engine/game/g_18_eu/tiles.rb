# frozen_string_literal: true

module Engine
  module Game
    module G18EU
      module Tiles
        TILE_TYPE = :lawson
        FIRST_OR_MINOR_TILE_LAYS = [{ lay: true, upgrade: false }, { lay: true, upgrade: false }].freeze
        MINOR_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
        TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        TILES = {
          '3' => 8,
          '4' => 10,
          '7' => 4,
          '8' => 15,
          '9' => 15,
          '14' => 4,
          '15' => 4,
          '57' => 8,
          '58' => 14,
          '80' => 4,
          '81' => 4,
          '82' => 4,
          '83' => 4,
          '141' => 5,
          '142' => 4,
          '143' => 2,
          '144' => 2,
          '145' => 4,
          '146' => 5,
          '147' => 4,
          '201' => 7,
          '202' => 9,
          '513' => 5,
          '544' => 3,
          '545' => 3,
          '546' => 3,
          '576' => 4,
          '577' => 4,
          '578' => 3,
          '579' => 3,
          '580' => 1,
          '581' => 2,
          '582' => 9,
          '583' => 1,
          '584' => 2,
          '611' => 8,
        }.freeze
      end
    end
  end
end
