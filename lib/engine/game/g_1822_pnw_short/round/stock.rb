# frozen_string_literal: true

require_relative '../../g_1822_pnw/round/stock'

module Engine
  module Game
    module G1822PnwShort
      module Round
        class Stock < Engine::Game::G1822PNW::Round::Stock
          def float_minor(bid)
            super

            return unless bid.company.id == @game.paired_assoc

            # float the unassociated minor paired with the associated minor from
            # bidbox 1

            company = @game.company_by_id(@game.paired_unassoc)

            minor = @game.find_corporation(company)

            minor.reservation_color = :white

            share_price = @game.stock_market.par_prices.find { |pp| pp.price == 50 }
            @game.stock_market.set_par(minor, share_price)
            bundle = minor.shares[0].to_bundle
            bundle.share_price = 0
            @game.share_pool.buy_shares(bid.entity, bundle)
            @game.after_par(minor)

            @game.bank.spend(100, minor)

            @game.companies.delete(company)
          end
        end
      end
    end
  end
end
