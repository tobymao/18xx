# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class SpecialToken < Base
      include Tokener

      def actions(entity)
        return [] if !ability(entity) || available_tokens(entity).empty?

        actions = ['place_token']
        actions << 'pass' if entity == @round.teleported
        actions
      end

      def description
        'Place teleport token'
      end

      def pass_description
        'Pass (Token)'
      end

      def blocks?
        can_token_after_teleport?
      end

      def blocking?
        can_token_after_teleport?
      end

      def round_state
        state = @round.respond_to?(:teleported) ? {} : { teleported: nil, teleport_tokener: nil }
        state.merge(super)
      end

      def can_token_after_teleport?
        @round.teleported && !available_tokens(@round.teleported).empty?
      end

      def active_entities
        @round.teleported ? [@round.teleported] : super
      end

      def process_place_token(action)
        entity = action.entity

        hex = action.city.hex
        city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
        raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(entity, hex)

        special_ability = ability(entity)
        check_tokenable =
          if special_ability.respond_to?(:check_tokenable)
            special_ability.check_tokenable
          else
            true
          end

        connected = special_ability.type == :token ? special_ability.connected : false
        place_token(
          @game.token_owner(entity),
          action.city,
          action.token,
          connected: connected,
          special_ability: special_ability,
          check_tokenable: check_tokenable,
        )

        if special_ability.type == :token
          special_ability.use!

          if special_ability.count&.zero? && special_ability.closed_when_used_up
            company = special_ability.owner
            @log << "#{company.name} closes"
            company.close!
          end
        end

        teleport_complete if @round.teleported
      end

      def process_pass(action)
        @log << "#{action.entity.owner.name} (#{action.entity.id}) declines to place token"
        teleport_complete
      end

      def teleport_complete
        ability = ability(@round.teleported)
        @round.teleported.remove_ability(ability) if ability
        @round.teleported = nil
      end

      def available_hex(entity, hex)
        ability = ability(entity)

        return if ability.hexes && !ability.hexes.empty? && !ability.hexes.include?(hex.id)

        if ability.type == :token && ability.connected
          return @game.token_graph_for_entity(entity.owner).reachable_hexes(entity.owner)[hex]
        end

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def available_tokens(entity)
        ability = ability(entity)
        return [Engine::Token.new(entity.owner)] if %i[teleport token].include?(ability&.type) && !ability.from_owner

        super(@game.token_owner(entity))
      end

      def min_token_price(tokens)
        return 0 if @round.teleported

        super
      end

      def ability(entity)
        return unless entity&.company?

        @game.abilities(entity, :token) do |ability, _company|
          return ability
        end

        @game.abilities(entity, :teleport) do |ability, _company|
          return ability if ability.used?
        end

        nil
      end
    end
  end
end
