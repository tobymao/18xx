# frozen_string_literal: true

require_relative '../action/lay_tile'
require_relative '../corporation'
require_relative '../player'
require_relative 'base'

module Engine
  module Round
    class Special < Base
      def active_entities
        @entities
      end

      def current_entity=(new_entity)
        @current_entity = new_entity
        @layable_hexes = nil
      end

      def tile_laying_ability
        return {} unless (ability = @current_entity&.abilities(:tile_lay))

        ability
      end

      def can_lay_track?
        !!tile_laying_ability
      end

      def layable_hexes
        @layable_hexes ||= tile_laying_ability[:hexes]&.map do |coordinates|
          hex = @game.hex_by_id(coordinates)
          [hex, hex.neighbors.keys]
        end.to_h
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
        company = action.entity
        case action
        when Action::LayTile
          lay_tile(action)
          company.remove_ability(:tile_lay)
          @game.round.clear_route_cache if @game.round.operating?
        when Action::BuyShare
          owner = company.owner
          share = action.share
          raise GameError,"Exchanging company would exceed limits"  unless can_gain?(share, owner)
          @game.share_pool.buy_share(owner, share, exchange: company)
          company.close!
        end
      end

      def potential_tiles
        return [] unless (tiles = tile_laying_ability[:tiles])

        tiles.map do |name|
          # this is shit
          @game.tiles.find { |t| t.name == name }
        end.compact
      end
    end
  end
end
