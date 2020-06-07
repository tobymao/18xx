# frozen_string_literal: true

require_relative '../action/lay_tile'
require_relative '../corporation'
require_relative '../player'
require_relative 'base'

module Engine
  module Round
    class Special < Base
      attr_writer :current_entity

      def active_entities
        @entities
      end

      def tile_laying_ability
        return {} unless (ability = @current_entity&.abilities(:tile_lay))

        ability
      end

      def can_lay_track?
        !!tile_laying_ability
      end

      def connected_hexes
        (tile_laying_ability[:hexes] || []).map do |coordinates|
          hex = @game.hex_by_id(coordinates)
          next unless hex.tile.preprinted

          [hex, hex.neighbors.keys]
        end.compact.to_h
      end

      private

      def _process_action(action)
        company = action.entity
        case action
        when Action::LayTile
          lay_tile(action)
          ability = company.abilities(:tile_lay)
          ability[:count] ||= 0
          ability[:count] -= 1
          company.remove_ability(:tile_lay) unless ability[:count].positive?
        when Action::BuyShare
          owner = company.owner
          share = action.share
          raise GameError, 'Exchanging company would exceed limits' unless can_gain?(share, owner)

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

      def check_track_restrictions!(_old_tile, _new_tile)
        true
      end
    end
  end
end
