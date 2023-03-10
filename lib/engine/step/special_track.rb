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

        action.type == :tile_lay && action.blocks ? self.class::ACTIONS : self.class::ACTIONS_WITH_PASS
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
        state = @round.respond_to?(:teleported) ? {} : { teleported: nil, teleport_tokener: nil }
        state.merge(super)
      end

      def process_lay_tile(action)
        if @company && (@company != action.entity) &&
           (ability = @game.abilities(@company, :tile_lay, time: 'track')) &&
           ability.must_lay_together && ability.must_lay_all
          raise GameError, "Cannot interrupt #{@company.name}'s tile lays"
        end

        ability = abilities(action.entity)
        owner = if !action.entity.owner
                  nil
                elsif action.entity.owner.corporation?
                  action.entity.owner
                else
                  @game.current_entity
                end
        if ability.type == :teleport ||
           (ability.type == :tile_lay && ability.consume_tile_lay)
          lay_tile_action(action, spender: owner)
        else
          lay_tile(action, spender: owner)
          ability.laid_hexes << action.hex.id
          @round.laid_hexes << action.hex
          check_connect(action, ability)
        end
        ability.use!

        # Record any track laid after the dividend step
        if owner&.corporation? && (operating_info = owner.operating_history[[@game.turn, @round.round_num]])
          operating_info.laid_hexes = @round.laid_hexes
        end

        if ability.type == :tile_lay
          if ability.count&.zero? && ability.closed_when_used_up
            company = ability.owner
            @log << "#{company.name} closes"
            company.close!
          end
          @company = ability.count.positive? ? action.entity : nil if ability.must_lay_together
        end

        return unless ability.type == :teleport

        company = ability.owner
        tokener = company.owner
        tokener = @game.current_entity if tokener.player?
        if tokener.tokens_by_type.empty?
          company.remove_ability(ability)
        else
          @round.teleported = company
          @round.teleport_tokener = tokener
        end
      end

      def process_pass(action)
        entity = action.entity
        ability = abilities(entity)
        raise GameError, "Not #{entity.name}'s turn: #{action.to_h}" unless entity == @company

        raise GameError, "#{entity.name} must use all its tile lays" if ability.must_lay_all && ability.count.positive?

        entity.remove_ability(ability)
        @log << "#{entity.owner.name} passes laying additional track with #{entity.name}"
        @company = nil
      end

      def available_hex(entity, hex)
        return unless (ability = abilities(entity))
        return tracker_available_hex(entity, hex) if ability.hexes&.empty? && ability.consume_tile_lay

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
          .select do |t|
          @game.tile_valid_for_phase?(t, hex: hex, phase_color_cache: potential_tile_colors(entity, hex)) &&
          @game.upgrades_to?(hex.tile, t, special, selected_company: entity)
        end
      end

      def abilities(entity, **kwargs, &block)
        return unless entity&.company?

        if @round.respond_to?(:just_sold_company) && entity == @round.just_sold_company
          ability = @game.abilities(entity, :tile_lay, time: 'sold', **kwargs, &block)
          return ability if ability
        end

        possible_times = [
          '%current_step%',
          'owning_corp_or_turn',
          'owning_player_or_turn',
          'owning_player_track',
          'or_between_turns',
          'stock_round',
        ]

        %i[tile_lay teleport].each do |type|
          ability = @game.abilities(
                            entity,
                            type,
                            time: possible_times,
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

        # check to see if at least one path on each laid tile connects to at least one path on one of the others
        #
        connected = {}
        laid_hexes = ability.laid_hexes.map { |h| @game.hex_by_id(h) }
        laid_hexes.each do |hex|
          next if connected[hex]

          laid_hexes.each do |other|
            next if hex == other

            if hex.tile.paths.any? { |a| other.tile.paths.any? { |b| a.connects_to?(b, nil) } }
              connected[hex] = 1
              connected[other] = 1
            end
          end
        end

        raise GameError, 'Paths must be connected' if connected.keys.size != laid_hexes.size
      end
    end
  end
end
