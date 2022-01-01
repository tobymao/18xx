# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18NewEngland
      module Step
        class IssueShares < Engine::Step::IssueShares
          def description
            'Issue Shares'
          end

          def pass_description
            'Skip (Issue)'
          end

          def redeemable_shares(_entity)
            []
          end

          def issuable_shares(entity)
            return [] if @round.redeemed

            super
          end
        end
      end
    end
  end
end
