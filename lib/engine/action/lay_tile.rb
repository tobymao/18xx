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
          game.player_by_name(@entity.name), # this should actually be a corporation
          game.tile_by_name(@tile.name),
          game.hex_by_name(@hex.name),
          @rotation,
        )
      end
    end
  end
end
