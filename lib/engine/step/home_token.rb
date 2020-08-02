# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class HomeToken < Base
      include Tokener
      ACTIONS = %w[place_token].freeze

      def actions(entity)
        return [] unless entity == pending_entity

        ACTIONS
      end

      def round_state
        {
          pending_tokens: [],
        }
      end

      def active?
        pending_entity
      end

      def current_entity
        pending_entity
      end

      def pending_entity
        pending_token[:entity]
      end

      def token
        pending_token[:token]
      end

      def pending_token
        @round.pending_tokens&.first || {}
      end

      def description
        if current_entity != token.corporation
          "Place #{token.corporation.name} Home Token"
        elsif token.corporation.tokens.first == token
          'Place Home Token'
        else
          'Place Token'
        end
      end

      def available_hex(_entity, hex)
        pending_token[:hexes].include?(hex)
      end

      def available_tokens
        [token]
      end

      def process_place_token(action)
        # the action is faked and doesn't represent the actual token laid
        hex = action.city.hex
        @game.game_error("Cannot place token on #{hex.name}") unless available_hex(action.entity, hex)

        place_token(
          token.corporation,
          action.city,
          token,
          teleport: true,
        )
        @round.pending_tokens.shift
      end
    end
  end
end
