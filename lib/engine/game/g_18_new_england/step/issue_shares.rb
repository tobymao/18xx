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
            issue_price = if bundle.owner == @game.bank
                            bundle.num_shares * corp.original_par_price.price
                          else
                            bundle.price
                          end
            @log << "#{corp.name} issues #{share_str(bundle)} of #{corp.name} to the market"\
                    " and receives #{@game.format_currency(issue_price)}"
            @game.share_pool.transfer_shares(bundle,
                                             @game.share_pool,
                                             spender: @game.bank,
                                             receiver: corp,
                                             price: issue_price)
            price = corp.share_price.price
            bundle.num_shares.times { @game.stock_market.move_left(corp) }
            @game.log_share_price(corp, price)
          end

          def share_str(bundle)
            ipo = if bundle.owner == @game.bank
                    'IPO '
                  else
                    ''
                  end
            num_shares = bundle.num_shares
            return "a #{bundle.percent}% #{ipo}share" if num_shares == 1

            "#{num_shares} #{ipo}shares"
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
