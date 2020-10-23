# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class SpecialToken < Base
      include Tokener

      ACTIONS = %w[place_token].freeze

      def actions(entity)
        return [] unless ability(entity)

        ACTIONS
      end

      def blocks?
        false
      end

      def process_place_token(action)
        entity = action.entity

        hex = action.city.hex
        city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
        @game.game_error("Cannot place token on #{hex.name}#{city_string}") unless available_hex(entity, hex)

        place_token(
          entity.owner,
          action.city,
          action.token,
          teleport: ability(entity).teleport_price,
          special_ability: ability(entity),
        )
      end

      def available_hex(entity, hex)
        return if ability(entity).hexes.any? && !ability(entity).hexes.include?(hex.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def available_tokens(entity)
        return super unless ability(entity)&.extra

        [Engine::Token.new(entity.owner)]
      end

      def ability(entity)
        return unless entity&.company?

        entity.abilities(:token)
      end
    end
  end
end
