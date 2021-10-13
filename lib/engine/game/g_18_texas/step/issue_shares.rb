# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18Texas
      module Step
        class IssueShares < Engine::Step::IssueShares
          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
            pass!
          end
        end
      end
    end
  end
end
