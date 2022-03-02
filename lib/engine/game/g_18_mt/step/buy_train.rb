# frozen_string_literal: true

require_relative '../../../step/buy_train'
require_relative 'train'

module Engine
  module Game
    module G18MT
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          include G18MT::Train

          def actions(entity)
            return [] unless can_entity_buy_train?(entity)

            return ['sell_shares'] if entity == current_entity&.owner && can_ebuy_sell_shares?(current_entity)

            return [] if entity != current_entity

            return %w[sell_shares buy_train] if must_issue_before_ebuy?(entity)
            return %w[sell_shares buy_train] if president_may_contribute?(entity)

            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def process_sell_shares(action)
            @last_share_issued_price = action.bundle.price_per_share if action.entity == current_entity
            super
          end

          def round_state
            super.merge(
              {
                train_buy_available: true,
              }
            )
          end

          def setup
            @round.train_buy_available = true
            super
          end

          def pass!
            @round.train_buy_available = false
            super
          end
        end
      end
    end
  end
end
