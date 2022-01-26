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
            @round.issued.positive? ? 'Done (Issue)' : 'Skip (Issue)'
          end

          def redeemable_shares(_entity)
            []
          end

          def issuable_shares(entity)
            return [] if @round.redeemed

            super
          end

          def log_pass(entity)
            return super unless @round.issued.positive?

            @log << "#{entity.name} finishes #{description.downcase}"
          end

          def pass!
            if @round.issued.positive?
              # drop share price after all issuing is done
              price = current_entity.share_price.price
              @round.issued.times { @game.stock_market.move_left(current_entity) }
              @game.log_share_price(current_entity, price)
            end

            super
          end

          def process_sell_shares(action)
            corp = action.entity
            bundle = action.bundle
            @round.issued += bundle.num_shares
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
            @round.issued = 0
            super
          end

          def round_state
            super.merge(
              {
                issued: 0,
              }
            )
          end
        end
      end
    end
  end
end
