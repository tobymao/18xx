# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class IssueShares < Engine::Step::IssueShares
          def process_sell_shares(action)
            @game.sell_shares_and_change_price(action.bundle)
          end

          def blocks?
            false
          end

          def dividend_step_passes
            pass!
          end
        end
      end
    end
  end
end
