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

        place_token(
          entity.owner,
          action.city,
          action.token,
          connected: false,
          special_ability: ability(entity),
        )

        teleport_complete if @round.teleported
      end

      def process_pass(action)
        @log << "#{action.entity.owner.name} (#{action.entity.sym}) declines to place token"
        teleport_complete
      end

      def teleport_complete
        ability = ability(@round.teleported)
        @round.teleported.remove_ability(ability) if ability
        @round.teleported = nil
      end

      def available_hex(entity, hex)
        return if !ability(entity).hexes.empty? && !ability(entity).hexes.include?(hex.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def available_tokens(entity)
        ability = ability(entity)
        return super unless ability&.type == :token && ability.extra

        [Engine::Token.new(entity.owner)]
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
