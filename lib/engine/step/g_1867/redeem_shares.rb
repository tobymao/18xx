# frozen_string_literal: true

require_relative '../base'
require_relative '../issue_shares'

module Engine
  module Step
    module G1867
      class RedeemShares < IssueShares
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
          'Skip (Redeem)'
        end
      end
    end
  end
end
