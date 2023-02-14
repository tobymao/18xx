# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G1868WY
      module Step
        class IssueShares < Engine::Step::IssueShares
          def round_state
            {
              issued: 0,
            }
          end

          def setup
            @round.issued = 0
            @redeemed = false
          end

          def issue_text(_entity)
            'Issue'
          end

          def issuable_shares(entity)
            @redeemed ? [] : @game.issuable_shares(entity, @round.issued)
          end

          def redeemable_shares(entity)
            @round.issued.positive? || entity.trains.empty? ? [] : @game.redeemable_shares(entity)
          end

          def blocks?
            false
          end

          def process_sell_shares(action)
            bundle = action.bundle

            @game.sell_shares_and_change_price(bundle)
            @round.issued += bundle.num_shares
          end

          def process_buy_shares(action)
            @game.share_pool.buy_shares(action.entity, action.bundle)
            @redeemed = true
          end
        end
      end
    end
  end
end
