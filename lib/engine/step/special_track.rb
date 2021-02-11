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
        action = abilities(entity)
        return [] unless action

        action.type == :tile_lay && action.blocks ? ACTIONS : ACTIONS_WITH_PASS
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

      def round_state
        super.merge(
          {
            teleported: nil,
          }
        )
      end

      def process_lay_tile(action)
        if @company && (@company != action.entity) &&
           (ability = @game.abilities(@company, :tile_lay, time: 'track')) &&
           ability.must_lay_together && ability.must_lay_all
          raise GameError, "Cannot interrupt #{@company.name}'s tile lays"
        end

        ability = abilities(action.entity)
        spender = if !action.entity.owner
                    nil
                  elsif action.entity.owner.corporation?
                    action.entity.owner
                  else
                    @game.current_entity
                  end
        if ability.type == :teleport
          lay_tile_action(action, spender: spender)
        else
          lay_tile(action, spender: spender)
          check_connect(action, ability)
        end
        ability.use!

        if ability.type == :tile_lay
          ability.owner.close! unless ability.count.positive? || !ability.closed_when_used_up
          @company = ability.count.positive? ? action.entity : nil if ability.must_lay_together
        end

        return unless ability.type == :teleport

        company = ability.owner
        if company.owner.tokens_by_type.empty?
          company.remove_ability(ability)
        else
          @round.teleported = company
        end
      end

      def process_pass(action)
        entity = action.entity
        ability = abilities(entity)
        raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @company

        entity.remove_ability(ability)
        @log << "#{entity.owner.name} passes laying additional track with #{entity.name}"
        @company = nil
      end

      def available_hex(entity, hex)
        hex_neighbors(entity, hex)
      end

      def hex_neighbors(entity, hex)
        return unless (ability = abilities(entity))
        return if !ability.hexes&.empty? && !ability.hexes&.include?(hex.id)

        operator = entity.owner.corporation? ? entity.owner : @game.current_entity
        return if ability.type == :tile_lay && ability.reachable && !@game.graph.connected_hexes(operator)[hex]

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def potential_tiles(entity, hex)
        return [] unless (tile_ability = abilities(entity))

        tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
        tiles = @game.tiles.uniq(&:name) if tile_ability.tiles.empty?

        special = tile_ability.special if tile_ability.type == :tile_lay
        tiles
          .compact
          .select { |t| @game.phase.tiles.include?(t.color) && @game.upgrades_to?(hex.tile, t, special) }
      end

      def abilities(entity, **kwargs, &block)
        return unless entity&.company?

        if @round.respond_to?(:just_sold_company) && entity == @round.just_sold_company
          ability = @game.abilities(entity, :tile_lay, time: 'sold', **kwargs, &block)
          return ability if ability
        end

        %i[tile_lay teleport].each do |type|
          ability = @game.abilities(
                            entity,
                            type,
                            time: %w[special_track %current_step% owning_corp_or_turn],
                            **kwargs,
                            &block
                          )
          return ability if ability && (ability.type != :teleport || !ability.used?)
        end

        nil
      end

      def check_connect(_action, ability)
        return if @game.loading
        return if ability.type == :teleport
        return unless ability.connect
        return if ability.hexes.size < 2
        return if !ability.start_count || ability.start_count < 2 || ability.start_count == ability.count

        paths = ability.hexes.flat_map do |hex_id|
          @game.hex_by_id(hex_id).tile.paths
        end.uniq

        raise GameError, 'Paths must be connected' if paths.size != paths[0].select(paths).size
      end
    end
  end
end
