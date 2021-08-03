# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Texas
      module Step
        class RedeemShares < Engine::Step::Base
          def actions(entity)
            available_actions = []
            return available_actions unless entity.corporation?
            return available_actions if entity != current_entity

            available_actions << 'buy_shares' unless redeemable_shares(entity).empty?
            available_actions << 'pass' if blocks? && !available_actions.empty?

            available_actions
          end

          def description
            'Redeem Shares'
          end

          def pass_description
            'Skip Redeem'
          end

          def process_buy_shares(action)
            @game.share_pool.buy_shares(action.entity, action.bundle)
            pass!
          end

          def share_pool?
            false
          end

          def redeemable_shares(entity)
            return [] unless entity.operating_history.size > 1

            bundles_for_corporation(share_pool, entity)
              .reject { entity.cash < bundle.price }
          end
        end
      end
    end
  end
end
