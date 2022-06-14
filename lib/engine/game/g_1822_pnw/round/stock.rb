# frozen_string_literal: true

require_relative '../../g_1822/round/stock'

module Engine
  module Game
    module G1822PNW
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

          def remove_l_trains(count)
            total_count = count
            removed_trains = 0
            while (train = @game.depot.upcoming.first).name == 'L' && count.positive?
              @game.send_train_to_ndem(train)
              count -= 1
              removed_trains += 1
            end
            @game.log << if total_count != removed_trains
                           "#{total_count} minors with no bids. The last #{removed_trains} L trains have "\
                             'been removed and given to the NDEM'
                         else
                           "#{total_count} minors with no bids. #{removed_trains} L trains have been removed "\
                             'and given to the NDEM'
                         end
          end

          def remove_minor_and_first_train(company)
            train = @game.depot.upcoming.first
            @game.log << "No bids on minor #{company.id}, it will close and a #{train.name} train is given to the NdeM"
            @game.send_train_to_ndem(train)

            ## Find the correct minor in the corporations and close it
            @game.replace_minor_with_ndem(company)
          end

          def sold_out?(corporation)
            corporation.id != 'NDEM' && super
          end

          def sold_out_stock_movement(corp)
            @game.stock_market.move_right(corp)
          end
        end
      end
    end
  end
end
