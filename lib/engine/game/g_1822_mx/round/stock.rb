# frozen_string_literal: true

require_relative '../../g_1822/round/stock'

module Engine
  module Game
    module G1822MX
      module Round
        class Stock < Engine::Game::G1822::Round::Stock
          def buy_company(bid)
            super
            return unless bid.company.id == 'C1'

            player = bid.entity
            company = @game.company_by_id('M18')
            company.owner = player
            player.companies << company

            minor = @game.find_corporation(company)
            minor.reservation_color = :white

            share_price = @game.stock_market.par_prices.find { |pp| pp.price == 50 }
            @game.stock_market.set_par(minor, share_price)
            @game.bank.spend(100, minor)

            @game.share_pool.transfer_shares(ShareBundle.new(minor.shares.first), player)
            @game.after_par(minor)
          end
        end
      end
    end
  end
end
