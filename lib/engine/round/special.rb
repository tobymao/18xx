# frozen_string_literal: true

require 'engine/round/base'

module Engine
  module Round
    class Special < Base
      attr_accessor :current_entity

      def layable_hexes
        @current_entity
      end

      def legal_rotations(hex, tile)
        original_exits = hex.tile.exits

        (0..5).select do |rotation|
          exits = tile.exits.map { |e| tile.rotate(e, rotation) }
          # connected to a legal route and not pointed into an offboard space
          (exits & layable_hexes[hex]).any? &&
            ((original_exits & exits).size == original_exits.size) &&
            exits.all? { |direction| hex.neighbors[direction] }
        end
      end
    end
  end
end
