# frozen_string_literal: true

require_relative '../action/assign'
require_relative '../action/lay_tile'
require_relative '../corporation'
require_relative '../hex'
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

      def map_abilities
        tile_laying_ability || assign_ability || token_ability
      end

      def tile_laying_ability
        @current_entity&.abilities(:tile_lay)
      end

      def assign_ability
        @current_entity&.abilities(:assign_hexes)
      end

      def token_ability
        @current_entity&.abilities(:token)
      end

      def assign_corporation_ability
        @current_entity&.abilities(:assign_corporation)
      end

      def can_assign_hex?
        !!assign_ability
      end

      def can_assign_corporation?
        !!assign_corporation_ability
      end

      def can_lay_track?
        !!tile_laying_ability
      end

      def can_place_token?
        !!token_ability
      end

      def connected_hexes
        hexes = (assign_ability || tile_laying_ability).hexes || []

        hexes.map do |coordinates|
          hex = @game.hex_by_id(coordinates)
          [hex, hex.neighbors.keys]
        end.to_h
      end

      def reachable_hexes
        hexes = token_ability.hexes || []

        hexes.map do |coordinates|
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
        when Action::Assign
          target = action.target
          if target.is_a?(Hex) && company.abilities(:assign_hexes)
            target.assign!(company.id)
            company.abilities(:assign_hexes, &:use!)
            @game.log << "#{company.name} is assigned to #{target.name}"
          end
          if target.is_a?(Corporation) && company.abilities(:assign_corporation)
            target.assign!(company.id)
            company.abilities(:assign_corporation, &:use!)
            @game.log << "#{company.name} is assigned to #{target.name}"
          end
        when Action::PlaceToken
          city = action.city
          hex = action.city.hex

          placed = false
          company.abilities(:token) do |_, _|
            next unless city.reserved_by?(company)

            token = action.token
            action.city.place_token(company.owner, token, free: true)
            company.abilities(:token, &:use!)
            @game.graph.clear
            @log << "#{company.name} places token in #{hex.id} for #{company.owner.name}"
            placed = true
          end
          raise GameError, "#{company.name} can't play token there" unless placed
        end
      end

      def potential_tiles(hex)
        return [] unless (tiles = tile_laying_ability&.tiles)

        potentials = tiles.map do |name|
          # this is shit
          @game.tiles.find { |t| t.name == name }
        end.compact
        potentials.select { |t| hex.tile.upgrades_to?(t) }
      end

      def check_track_restrictions!(_old_tile, _new_tile)
        true
      end
    end
  end
end
