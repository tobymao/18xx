# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18NewEngland
      module Step
        class RedeemShares < Engine::Step::IssueShares
          def issuable_shares(_entity)
            []
          end

          def redeemable_shares(entity)
            return [] if @round.issued.positive?

            super
          end

          def description
            'Redeem Shares'
          end

          def pass_description
            'Skip (Redeem)'
          end

          def process_buy_shares(action)
            @round.redeemed = true
            super
          end

          def blocks?
            false
          end

          def setup
            @round.redeemed = nil
            super
          end

          def round_state
            super.merge(
              {
                redeemed: nil,
              }
            )
          end
        end
      end
    end
  end
end
