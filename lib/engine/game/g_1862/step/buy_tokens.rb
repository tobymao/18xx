# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1862
      module Step
        class BuyTokens < Engine::Step::Base
          UNCHARTERED_TOKEN_COST = 40

          def actions(entity)
            return [] unless @game.acting_for_entity(@round.buy_tokens) == entity

            %w[choose]
          end

          def active_entities
            [@game.acting_for_entity(@round.buy_tokens)]
          end

          def active?
            !!@round.buy_tokens
          end

          def current_entity
            @game.acting_for_entity(@round.buy_tokens)
          end

          def description
            'Buy Tokens' if @round.buy_tokens
          end

          def process_choose(action)
            corporation = @round.buy_tokens
            @game.purchase_tokens!(corporation, action.choice.to_i)

            @round.buy_tokens = nil
            pass!
          end

          def choice_available?(entity)
            @round.buy_tokens == entity
          end

          def choice_name
            'Number of Tokens to Buy'
          end

          def choices
            Array.new(6) do |i|
              next unless (i + 2) * UNCHARTERED_TOKEN_COST <= @round.buy_tokens.cash

              [i + 2, "#{i + 2} (#{@game.format_currency((i + 2) * UNCHARTERED_TOKEN_COST)})"]
            end.compact.to_h
          end

          def visible_corporations
            [@round.buy_tokens]
          end

          def round_state
            super.merge(
              {
                buy_tokens: nil,
              }
            )
          end
        end
      end
    end
  end
end
