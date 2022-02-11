# frozen_string_literal: true

require_relative 'base'
require_relative 'token_merger'

module Engine
  module Step
    class ReduceTokens < Base
      include TokenMerger
      REMOVE_TOKEN_ACTIONS = %w[remove_token].freeze

      def description
        "Choose tokens to remove to drop below limit of #{@game.class::LIMIT_TOKENS_AFTER_MERGER} tokens"
      end

      def actions(entity)
        return [] unless current_entity == entity

        REMOVE_TOKEN_ACTIONS
      end

      def active?
        @round.corporations_removing_tokens
      end

      def active_entities
        [@round.corporations_removing_tokens&.first].compact
      end

      def surviving
        @round.corporations_removing_tokens&.first
      end

      def acquired_corps
        @round.corporations_removing_tokens&.drop(1)
      end

      def can_replace_token?(_entity, token)
        return false unless token

        @round.corporations_removing_tokens.include?(token.corporation)
      end

      def process_remove_token(action)
        entity = action.entity
        slot = action.slot
        city_tokens = action.city.tokens.size
        token = slot < city_tokens ? action.city.tokens[action.slot] : action.city.extra_tokens[action.slot - city_tokens]
        raise GameError, "Cannot remove #{token.corporation.name} token" unless available_hex(entity, token.city.hex)

        token.remove!
        @log << "#{action.entity.name} removes token from #{action.city.hex.name}"

        return if tokens_above_limits?(entity, acquired_corps)

        move_tokens_to_surviving(entity, acquired_corps)
        @round.corporations_removing_tokens = nil
      end

      def available_hex(entity, hex)
        return false unless entity == surviving

        surviving_token = entity.tokens.find { |t| t.used && t.city && t.hex == hex }
        acquired_token = others_tokens(acquired_corps).find { |t| t.used && t.city && t.hex == hex }

        # Force user to clear up the NY tile first, then choose the others
        if tokens_in_same_hex(entity, acquired_corps)
          surviving_token && acquired_token
        else
          surviving_token || acquired_token
        end
      end
    end
  end
end
