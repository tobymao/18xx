# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CO
      class RedeemShares < Base
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

        def redeemable_shares(entity)
          # Done via Buy Shares
          @game.redeemable_shares(entity)
        end
      end
    end
  end
end
