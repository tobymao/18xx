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
        when Action::BuyShare
          owner = company.owner
          share = action.share
          corporation = share.corporation

          floated_before = corporation.floated?

          @game.share_pool.transfer_share(share, owner)
          @log << "#{owner.name} exchanges #{company.name} for a share of #{corporation.name}"
          presidential_share_swap(corporation, owner) if corporation.owner && corporation.owner != owner
          company.close!

          return if floated_before == corporation.floated?

          price = share.price
          @game.bank.spend(price * 10, corporation)
          @log << "#{corporation.name} floats with $#{corporation.cash} and tokens #{corporation.coordinates}"
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
