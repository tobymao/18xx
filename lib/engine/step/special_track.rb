# frozen_string_literal: true

require_relative 'base'
require_relative 'tracker'

module Engine
  module Step
    class SpecialTrack < Base
      include Tracker

      ACTIONS = %w[lay_tile].freeze

      def actions(entity)
        return [] unless ability(entity)

        ACTIONS
      end

      def blocks?
        false
      end

      def process_lay_tile(action)
        lay_tile(action)
        ability(action.entity).use!
      end

      def available_hex(entity, hex)
        return unless ability(entity).hexes.include?(hex.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def potential_tiles(entity, hex)
        colors = @game.phase.tiles
        (ability(entity)&.tiles || [])
          .map { |name| @game.tiles.find { |t| t.name == name } }
          .compact
          .select { |t| colors.include?(t.color) && hex.tile.upgrades_to?(t, true) }
      end

      def ability(entity)
        return unless entity.company?

        ability = entity.abilities(:tile_lay, 'sold') if @round.respond_to?(:just_sold_company) &&
          entity == @round.just_sold_company
        ability || entity.abilities(:tile_lay, 'track')
      end
    end
  end
end
