# frozen_string_literal: true

require_relative 'base'
require_relative 'tracker'

module Engine
  module Step
    class SpecialTrack < Base
      include Tracker

      attr_reader :company

      ACTIONS = %w[lay_tile].freeze
      ACTIONS_WITH_PASS = %w[lay_tile pass].freeze

      def actions(entity)
        action = tile_lay_abilities(entity)
        return [] unless action

        action.blocks ? ACTIONS : ACTIONS_WITH_PASS
      end

      def description
        "Lay Track for #{@company.name}"
      end

      def active_entities
        @company ? [@company] : super
      end

      def blocks?
        @company
      end

      def process_lay_tile(action)
        if @company && (@company != action.entity) &&
           (ability = @game.abilities(@company, :tile_lay, time: 'track')) &&
           ability.must_lay_together && ability.must_lay_all
          raise GameError, "Cannot interrupt #{@company.name}'s tile lays"
        end

        ability = tile_lay_abilities(action.entity)
        lay_tile(action, spender: action.entity.owner)
        check_connect(action, ability)
        ability.use!

        @company = ability.count.positive? ? action.entity : nil if ability.must_lay_together
      end

      def process_pass(action)
        entity = action.entity
        ability = tile_lay_abilities(entity)
        raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @company

        entity.remove_ability(ability)
        @log << "#{entity.owner.name} passes laying additional track with #{entity.name}"
        @company = nil
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

      def tile_lay_abilities(entity, **kwargs, &block)
        return unless entity&.company?

        if @round.respond_to?(:just_sold_company) && entity == @round.just_sold_company
          ability = @game.abilities(entity, :tile_lay, time: 'sold', **kwargs, &block)
        end

        ability ||
          @game.abilities(
            entity, :tile_lay, time: %w[special_track %current_step% owning_corp_or_turn], **kwargs, &block
          )
      end

      def check_connect(_action, ability)
        hex_ids = ability.hexes
        return unless ability.connect
        return if hex_ids.size < 2
        return if !ability.start_count || ability.start_count < 2 || ability.start_count == ability.count

        paths = hex_ids.flat_map do |hex_id|
          @game.hex_by_id(hex_id).tile.paths
        end.uniq

        raise GameError, 'Paths must be connected' if paths.size != paths[0].select(paths).size
      end
    end
  end
end
