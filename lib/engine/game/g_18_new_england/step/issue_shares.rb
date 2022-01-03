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
            @round.issued ? 'Done (Issue)' : 'Skip (Issue)'
          end

          def redeemable_shares(_entity)
            []
          end

          def issuable_shares(entity)
            return [] if @round.redeemed

            super
          end

          def process_sell_shares(action)
            @round.issued = true
            corp = action.entity
            bundle = action.bundle
            ipo = if bundle.owner == @game.bank
                    'IPO '
                  else
                    ''
                  end
            @log << "#{corp.name} issues a 10% #{ipo}share of #{corp.name} to market"\
                    " and receives #{@game.format_currency(bundle.price)}"
            @game.share_pool.sell_shares(bundle, silent: true)
            price = corp.share_price.price
            action.bundle.num_shares.times { @game.stock_market.move_left(corp) }
            @game.log_share_price(corp, price)
          end

          def setup
            @round.issued = nil
            super
          end

          def round_state
            super.merge(
              {
                issued: nil,
              }
            )
          end
        end
      end
    end
  end
end
