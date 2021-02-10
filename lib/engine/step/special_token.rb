# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class SpecialToken < Base
      include Tokener

      def actions(entity)
        return [] unless ability(entity)

        actions = ['place_token']
        actions << 'pass' if entity == @round.teleported
        actions
      end

      def description
        'Place teleport token'
      end

      def blocks?
        @round.teleported
      end

      def blocking?
        @round.teleported
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

        @game.abilities(entity, :token) do |ability, _owner|
          return ability
        end

        @game.abilities(entity, :teleport) do |ability, _owner|
          next unless ability.used?

          return ability
        end
      end
    end
  end
end
