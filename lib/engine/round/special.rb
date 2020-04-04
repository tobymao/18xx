# frozen_string_literal: true

require 'engine/action/lay_tile'
require 'engine/round/base'

module Engine
  module Round
    class Special < Base
      def active_entities
        @entities.select do |company|
          company.abilities[:tile_lay]
        end
      end

      def layable_hexes(company)
        return nil unless company&.owner
        return nil unless (ability = company.abilities[:tile_lay])

        hexes = ability[:hexes].map do |coordinates|
          hex = @game.hex_by_id(coordinates)
          [hex, hex.neighbors.keys]
        end.to_h

        tiles = ability[:tiles].map do |name|
          # this is shit
          @game.tiles.find { |t| t.name == name }
        end

        [hexes, tiles]
      end

      def legal_rotations(hex, tile)
        original_exits = hex.tile.exits

        (0..5).select do |rotation|
          exits = tile.exits.map { |e| tile.rotate(e, rotation) }
          ((original_exits & exits).size == original_exits.size) &&
            exits.all? { |direction| hex.neighbors[direction] }
        end
      end

      private

      def _process_action(action)
        case action
        when Action::LayTile
          lay_tile(action)
          action.entity.remove_ability(:tile_lay)
        end
      end
    end
  end
end
