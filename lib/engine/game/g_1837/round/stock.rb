# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1837
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            corporation.percent_ipo_buyable.zero? && corporation.num_market_shares.zero?
          end

          def sold_out_stock_movement(corp)
            if corporation.owner.percent_of(corporation) <= 40
              @game.stock_market.move_up(corp)
            else
              original_share_price = corporation.share_price
              @game.stock_market.move_left(corp)
              @game.stock_market.move_up(corp) if original_share_price != corporation.share_price
            end
          end
        end
      end
    end
  end
end
