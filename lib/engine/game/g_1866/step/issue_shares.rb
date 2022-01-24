# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1866
      module Step
        class IssueShares < Engine::Step::IssueShares
          def process_sell_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation
            price = corporation.share_price.price
            @game.share_pool.sell_shares(action.bundle)

            bundle.num_shares.times { @game.stock_market.move_left(corporation) }
            @game.log_share_price(corporation, price)
            pass!
          end

          def skip!
            pass!
          end
        end
      end
    end
  end
end
