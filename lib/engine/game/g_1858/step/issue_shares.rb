# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1858
      module Step
        class IssueShares < Engine::Step::IssueShares
          def issuable_shares(entity)
            # Can't issues shares on a company's first operating turn.
            return [] if entity.operating_history.one?

            @game.issuable_shares(entity)
          end

          def process_sell_shares(action)
            @game.share_pool.sell_shares(action.bundle)
            old_price = action.entity.share_price
            @game.stock_market.move_left(action.entity)
            @game.log_share_price(action.entity, old_price)
            pass!
          end

          def log_skip(entity)
            super unless entity.minor?
          end
        end
      end
    end
  end
end
