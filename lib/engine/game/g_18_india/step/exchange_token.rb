# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18India
      module Step
        class ExchangeToken < Engine::Step::HomeToken
          ACTIONS = %w[pass place_token].freeze

          def description
            "GIPR (#{current_entity.owner}) may use exchange tokens for tokens of #{token.corporation.name} or pass"
          end

          def round_state
            super.merge(
              {
                pending_exchange_tokens: [],
              }
            )
          end

          def pending_token
            @round.pending_exchange_tokens&.first || {}
          end

          def process_place_token(action)
            hex = action.city.hex

            @round.pending_exchange_tokens.shift
          end

          def process_pass(action)
            log_pass(action.entity)
            pass!
          end

          def log_pass(entity)
            @log << "#{entity.name} passes additional exchanges"
          end
        end
      end
    end
  end
end
