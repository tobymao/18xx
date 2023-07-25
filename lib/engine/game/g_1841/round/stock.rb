# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1841
      module Round
        class Stock < Engine::Round::Stock
          def finish_round
            corporations_to_move_price.sort.each do |corp|
              next unless corp.share_price

              old_price = corp.share_price

              sold_out_stock_movement(corp) if sold_out?(corp) && @game.sold_out_increase?(corp)
              pool_share_drop = @game.class::POOL_SHARE_DROP
              price_drops =
                if (pool_share_drop == :none) || (shares_in_pool = corp.num_market_shares).zero?
                  0
                elsif pool_share_drop == :one
                  @game.frozen?(corp) ? 2 : 1
                else
                  shares_in_pool
                end
              price_drops.times { @game.stock_market.move_down(corp) }

              @game.log_share_price(corp, old_price)
            end
            @game.finish_stock_round
          end
        end
      end
    end
  end
end
