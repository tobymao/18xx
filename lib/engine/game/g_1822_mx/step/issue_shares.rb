# frozen_string_literal: true

require_relative '../../g_1822/step/issue_shares'

module Engine
  module Game
    module G1822MX
      module Step
        class IssueShares < Engine::Game::G1822::Step::IssueShares
          def process_sell_shares(action)
            @game.share_pool.sell_shares(action.bundle)
            old_price = action.entity.share_price.price
            action.bundle.shares.size.times { @game.stock_market.move_left(action.entity) }
            @game.log_share_price(action.entity, old_price)
            pass!
          end
        end
      end
    end
  end
end
