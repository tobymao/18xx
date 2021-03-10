# frozen_string_literal: true

require_relative '../../../step/waterfall_auction'

module Engine
  module Game
    module G2038
      module Step
        class WaterfallAuction < Engine::Step::WaterfallAuction
          def buy_company(player, company, price)
            super

            @game.abilities(company, :launch) do |ability|

              corporation = @game.corporation_by_id(ability.corporation)

              target_price = @game.optional_short_game ? 67 : 100
              share_price = @game.stock_market.par_prices.find { |pp| pp.price == target_price }

              @game.stock_market.set_par(corporation, share_price)
              @game.share_pool.buy_shares(player, corporation.shares.first, exchange: :free)
              @game.after_par(corporation)
            end
          end
        end
      end
    end
  end
end
