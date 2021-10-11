# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1867
      module Step
        class RedeemShares < Engine::Step::IssueShares
          def actions(entity)
            available_actions = []
            return available_actions unless entity.corporation?
            return available_actions if entity != current_entity

            available_actions << 'buy_shares' unless redeemable_shares(entity).empty?
            available_actions << 'pass' if blocks? && !available_actions.empty?

            available_actions
          end

          def log_skip(entity)
            super if entity.type == :major
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
end
