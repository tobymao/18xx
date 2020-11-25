# frozen_string_literal: true

require_relative 'base'
require_relative 'tracker'

module Engine
  module Step
    class SpecialTrack < Base
      include Tracker

      ACTIONS = %w[lay_tile].freeze

      def actions(entity)
        return [] unless tile_lay_abilities(entity)

        ACTIONS
      end

      def blocks?
        false
      end

      def process_lay_tile(action)
        ability = tile_lay_abilities(action.entity)
        lay_tile(action, spender: action.entity.owner)
        check_connect(action, ability)
        ability.use!
      end

      def available_hex(entity, hex)
        return unless (ability = tile_lay_abilities(entity))
        return if ability.hexes&.any? && !ability.hexes&.include?(hex.id)
        return if ability.reachable && !@game.graph.connected_hexes(entity.owner)[hex]

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def potential_tiles(entity, hex)
        return [] unless (tile_ability = tile_lay_abilities(entity))

        tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
        tiles = @game.tiles.uniq(&:name) if tile_ability.tiles.empty?

        tiles
          .compact
          .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, tile_ability.special) }
      end

      def tile_lay_abilities(entity, &block)
        return unless entity&.company?

        ability = entity.abilities(:tile_lay, time: 'sold', &block) if @round.respond_to?(:just_sold_company) &&
          entity == @round.just_sold_company
        ability || entity.abilities(:tile_lay, time: 'track', &block)
      end

      def check_connect(_action, ability)
        hex_ids = ability.hexes
        return unless ability.connect
        return if hex_ids.size < 2
        return if !ability.start_count || ability.start_count < 2 || ability.start_count == ability.count

        paths = hex_ids.flat_map do |hex_id|
          @game.hex_by_id(hex_id).tile.paths
        end.uniq

        @game.game_error('Paths must be connected') if paths.size != paths[0].select(paths).size
      end
    end
  end
end
