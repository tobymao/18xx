# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module GSteamOverHolland
      module Step
        class IssueShares < Engine::Step::IssueShares
          def process_sell_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation
            old_price = corporation.share_price
            @game.share_pool.sell_shares(bundle)

            (bundle.num_shares - 1).times do
              @game.stock_market.move_left(corporation)
            end

            @game.log_share_price(corporation, old_price)
            @round.issued_shares[corporation] = true
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
