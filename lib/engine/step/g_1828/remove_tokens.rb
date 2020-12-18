# frozen_string_literal: true

require_relative '../base'
require_relative 'token_merger'

module Engine
  module Step
    module G1828
      class ReduceTokens < Base
        REMOVE_TOKEN_ACTIONS = %w[remove_token].freeze

        def description
          'Choose token to remove'
        end

        def actions(entity)
          return [] unless current_entity == entity

          REMOVE_TOKEN_ACTIONS
        end

        def active?
          corporation
        end

        def active_entities
          [corporation]
        end

        def corporation
          @round.corporation_removing_tokens
        end

        def hexes
          @round.hexes_to_remove_tokens
        end

        def round_state
          {
            corporation_removing_tokens: nil,
            hexes_to_remove_tokens: [],
          }
        end

        def process_remove_token(action)
          entity = action.entity
          token = action.city.tokens[action.slot]
          hex = action.city.hex
          @game.game_error("Cannot remove #{token.corporation.name} token") unless available_hex(entity, hex)

          blocking_token = Token.new(@game.blocking_corporation)
          token.swap!(blocking_token)
          @log << "#{action.entity.name} removes token from #{hex}"

          hexes.delete(hex)
          @round.corporations_removing_tokens = nil if hexes.empty?
        end

        def available_hex(entity, hex)
          return false unless entity == corporation

          hexes.include?(hex)
        end
      end
    end
  end
end
