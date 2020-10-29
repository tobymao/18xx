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

      def description
        "Lay Track for #{@company.name}"
      end

      def active_entities
        @company ? [@company] : super
      end

      def blocks?
        ability(@company)&.blocks
      end

      def process_lay_tile(action)
        tile_ability = ability(action.entity)
        lay_tile(action, spender: action.entity.owner)
        check_connect(action, tile_ability)
        tile_ability.use!
      end

      def available_hex(entity, hex)
        return if ability(entity)&.hexes&.any? && !ability(entity)&.hexes&.include?(hex.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def potential_tiles(entity, hex)
        return [] unless (tile_ability = ability(entity))

        tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
        tiles = @game.tiles.uniq(&:name) if tile_ability.tiles.empty?

        tiles
          .compact
          .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, tile_ability.special) }
      end

      def ability(entity)
        return unless entity&.company?

        ability = entity.abilities(:tile_lay, 'sold') if @round.respond_to?(:just_sold_company) &&
          entity == @round.just_sold_company
        ability || entity.abilities(:tile_lay, 'track')
      end

      def check_connect(action, tile_ability)
        company = action.entity
        hex_ids = tile_ability.hexes
        return if !tile_ability&.connect || hex_ids.size < 2

        if company == @company
          paths = hex_ids.flat_map do |hex_id|
            @game.hex_by_id(hex_id).tile.paths
          end.uniq

          @game.game_error('Paths must be connected') if paths.size != paths[0].select(paths).size
        end

        @company = company
      end

      def setup
        @company = nil
      end
    end
  end
end
