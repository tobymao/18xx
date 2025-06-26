# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18India
      module Step
        class ExchangeToken < Engine::Step::Base
          ACTIONS = %w[pass remove_token].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            ACTIONS
          end

          def process_remove_token(action)
            entity = action.entity
            return unless entity == @game.gipr

            closing_corp = token.corporation
            hex = action.city.hex
            token.swap!(exchange_token)
            entity.tokens << exchange_token
            token.destroy!
            @log << "GIPR replaced #{closing_corp.name} token at #{hex.name} with exchange token."
            @game.use_gipr_exchange_token

            @round.pending_exchange_tokens.clear if @game.gipr_exchange_tokens.zero?
            @round.pending_exchange_tokens.shift
          end

          def can_replace_token?(_entity, selected_token)
            return false unless selected_token

            selected_token == token
          end

          def description
            "GIPR (#{current_entity.owner.name}) may use exchange tokens for tokens of #{token.corporation.name} or pass"
          end

          def round_state
            super.merge(
              {
                pending_exchange_tokens: [],
                gipr_exchanging: false,
              }
            )
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

          def exchange_token
            pending_token[:exchange_token]
          end

          def pending_token
            @round.pending_exchange_tokens&.first || {}
          end

          def available_hex(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def available_tokens(_entity)
            [token]
          end

          def pass_description
            "Pass: Exchange with #{token.corporation.name} token at #{token.city.hex.name}"
          end

          def process_pass(action)
            entity = action.entity
            return unless entity == @game.gipr

            closing_corp = token.corporation
            hex = token.city.hex
            @log << "#{pending_entity.name} choose not to exchange with #{closing_corp.name} token at #{hex.name}"
            token.remove!
            @round.pending_exchange_tokens.shift
          end
        end
      end
    end
  end
end
