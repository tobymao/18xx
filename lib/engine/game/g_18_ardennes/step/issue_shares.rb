# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18Ardennes
      module Step
        class IssueShares < Engine::Step::IssueShares
          def description
            'Issue Shares'
          end

          def pass_description
            'Skip (Issue Shares)'
          end

          def log_skip(entity)
            super unless entity.type == :minor
          end

          def process_sell_shares(action)
            super

            corporation = action.entity
            bundle = action.bundle
            old_price = corporation.share_price
            bundle.num_shares.times { @game.stock_market.move_left(corporation) }
            @game.log_share_price(corporation, old_price)
          end
        end
      end
    end
  end
end
