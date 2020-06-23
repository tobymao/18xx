# frozen_string_literal: true

require_relative '../action/lay_tile'
require_relative '../corporation'
require_relative '../player'
require_relative 'base'

module Engine
  module Round
    class Special < Base
      attr_writer :current_entity

      def change_entity(_action)
        # Ignore change entity as special doesn't change entity
      end

      def active_entities
        @entities
      end

      def tile_laying_ability
        @current_entity&.abilities(:tile_lay)
      end

      def can_lay_track?
        !!tile_laying_ability
      end

      def connected_hexes
        return {} unless tile_laying_ability

        tile_laying_ability.hexes.map do |coordinates|
          hex = @game.hex_by_id(coordinates)
          [hex, hex.neighbors.keys]
        end.to_h
      end

      private

      def _process_action(action)
        company = action.entity
        case action
        when Action::LayTile
          lay_tile(action)
          company.abilities(:tile_lay, &:use!)
        when Action::BuyShares
          owner = company.owner
          bundle = action.bundle
          raise GameError, 'Exchanging company would exceed limits' unless can_gain?(bundle, owner)

          @game.share_pool.buy_shares(owner, bundle, exchange: company)
          company.close!
        end
      end

      def potential_tiles
        return [] unless (tiles = tile_laying_ability&.tiles)

        tiles.map do |name|
          # this is shit
          @game.tiles.find { |t| t.name == name }
        end.compact
      end

      def check_track_restrictions!(_old_tile, _new_tile)
        true
      end
    end
  end
end
