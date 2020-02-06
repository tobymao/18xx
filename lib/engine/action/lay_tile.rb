# frozen_string_literal: true

require 'engine/action/base'

module Engine
  module Action
    class LayTile < Base
      attr_reader :entity, :hex, :tile, :rotation

      def initialize(entity, tile, hex, rotation)
        @entity = entity
        @hex = hex
        @tile = tile
        @rotation = rotation
      end

      def copy(game)
        self.class.new(
          game.corportation_by_name(@entity.name),
          game.tile_by_id(@tile.id),
          game.hex_by_name(@hex.name),
          @rotation,
        )
      end
    end
  end
end
