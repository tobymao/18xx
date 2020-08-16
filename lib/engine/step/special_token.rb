# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'
require_relative '../game_error'

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
        token_ability = ability(entity)

        if token_ability.check_target(action.city)
          place_token(
            entity.owner,
            action.city,
            action.token,
            teleport: token_ability.teleport_price,
          )
        else
          raise GameError,
                "#{entity.name} ability can not be used to place token " \
                "in #{action.city.hex.id}."
        end
      end

      def available_hex(entity, hex)
        return unless ability(entity).hexes.include?(hex.id)

        @game.hex_by_id(hex.id).neighbors.keys
      end

      def available_tokens(entity)
        return super unless ability(entity)&.extra

        [Engine::Token.new(entity.owner)]
      end

      def ability(entity)
        return unless entity.company?

        entity.abilities(:token)
      end
    end
  end
end
