# frozen_string_literal: true

require_relative 'base'

module Engine
  module Action
    class LayTile < Base
      attr_reader :hex, :tile, :rotation

      def initialize(entity, tile:, hex:, rotation:)
        super(entity)
        @hex = hex
        @tile = tile
        @rotation = rotation
      end

      def self.h_to_args(h, game)
        {
          tile: game.tile_by_id(h['tile']),
          hex: game.hex_by_id(h['hex']),
          rotation: h['rotation'],
        }
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
