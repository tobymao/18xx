# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1858
      module Step
        class IssueShares < Engine::Step::IssueShares
          def process_sell_shares(action)
            @game.share_pool.sell_shares(action.bundle)
            old_price = action.entity.share_price
            @game.stock_market.move_left(action.entity)
            @game.log_share_price(action.entity, old_price)
            pass!
          end
        end
      end
    end
  end
end
