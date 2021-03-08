# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def buy_company(player, company, price)
            super

            # TODO: We should probably just remove the action from ST
            # TODO: and do the below without it, but we need to find
            # TODO: out how to get the president shares first. :)

            if company.sym == 'ST'
              @round.companies_pending_par.delete(company)
              share_price = @game.stock_market.par_prices.find { |pp| pp.price == 100 }

              @game.abilities(company, :shares).shares.each do |share|
                next unless share.president

                @game.stock_market.set_par(share.corporation, share_price)
                @game.share_pool.buy_shares(player, share.corporation.shares.first, exchange: :free)
                @game.after_par(share.corporation)
              end
            end

            return unless company.instance_of?(G2038::Company)

            company.close!   # remove our wrapper which was added in super.buy_company
            minor = @game.minors.find { |m| m.id == company.minor_id }
            minor.owner = player
            minor.float!
            capital = (price - 100) / 2
            @game.bank.spend(100 + capital, minor)
          end
        end
      end
    end
  end
end
