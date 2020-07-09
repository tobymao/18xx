# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class Token < Base
      include Tokener
      ACTIONS = %w[place_token pass].freeze

      def actions(entity)
        return [] if current_entity != entity ||
          !(token = entity.next_token) ||
          min_token_price(token) > entity.cash ||
          !@game.graph.can_token?(entity)

        ACTIONS
      end

      def description
        'Place a Token'
      end

      def pass_description
        'Skip (Token)'
      end

      def available_hex(hex)
        @game.graph.reachable_hexes(current_entity)[hex]
      end

      def sequential?
        true
      end

      def process_place_token(action)
        entity = action.entity

        place_token(entity, action.city, action.token)
        pass!
      end
    end
  end
end
