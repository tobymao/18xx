# frozen_string_literal: true

require_relative '../../../step/issue_shares'

module Engine
  module Game
    module G18Norway
      module Step
        class IssueShares < Engine::Step::IssueShares
          def process_sell_shares(action)
            corp = action.entity
            bundle = action.bundle
            issue_price = bundle.price
            @log << "#{corp.name} issues #{share_str(bundle)} of #{corp.name} to the market"\
                    " and receives #{@game.format_currency(issue_price)}"
            @game.share_pool.transfer_shares(bundle,
                                             @game.share_pool,
                                             spender: @game.bank,
                                             receiver: corp,
                                             price: issue_price)
          end

          def share_str(bundle)
            num_shares = bundle.num_shares
            return "a #{bundle.percent}% share" if num_shares == 1

            "#{num_shares} shares"
          end

          def dividend_step_passes
            pass!
          end

          def blocks?
            false
          end
        end
      end
    end
  end
end
