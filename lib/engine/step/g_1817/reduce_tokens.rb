# frozen_string_literal: true

require_relative '../base'
require_relative 'token_merger'

module Engine
  module Step
    module G1817
      class ReduceTokens < Base
        include TokenMerger
        REMOVE_TOKEN_ACTIONS = %w[remove_token].freeze

        def description
          "Choose tokens to remove to drop below limit of #{@game.class::LIMIT_TOKENS} tokens"
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

        def acquired_corp
          @round.corporations_removing_tokens&.last
        end

        def can_replace_token?(entity, token)
          return false unless token

          token.corporation == entity || token.corporation == acquired_corp
        end

        def process_remove_token(action)
          entity = action.entity
          token = action.city.tokens[action.slot]
          @game.game_error("Cannot remove #{token.corporation.name} token") unless available_hex(entity, token.city.hex)

          token.remove!
          @log << "#{action.entity.name} removes token from #{action.city.hex.name}"

          return if tokens_above_limits?(entity, acquired_corp)

          move_tokens_to_surviving(entity, acquired_corp)
          @round.corporations_removing_tokens = nil
        end

        def available_hex(entity, hex)
          return false unless entity == surviving

          surviving_token = entity.tokens.find { |t| t.used && t.city.hex == hex }
          acquired_token = acquired_corp.tokens.find { |t| t.used && t.city.hex == hex }

          # Force user to clear up the NY tile first, then choose the others
          if tokens_in_same_hex(entity, acquired_corp)
            surviving_token && acquired_token
          else
            surviving_token || acquired_token
          end
        end
      end
    end
  end
end
