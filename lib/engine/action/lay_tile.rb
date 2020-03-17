# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class LayTile < Base
      attr_reader :hex, :tile, :rotation

      def initialize(entity, tile, hex, rotation)
        @entity = entity
        @hex = hex
        @tile = tile
        @rotation = rotation
      end

      def self.h_to_args(h, game)
        [game.tile_by_id(h['tile']), game.hex_by_id(h['hex']), h['rotation']]
      end

      def args_to_h
        {
          'hex' => @hex.id,
          'tile' => @tile.id,
          'rotation' => @rotation,
        }
      end
    end
  end
end
