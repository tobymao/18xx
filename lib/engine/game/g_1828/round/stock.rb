# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1828
      module Round
        class Stock < Engine::Round::Stock
          protected

          def sold_out_stock_movement(corp)
            @game.stock_market.move_up(corp) if corp.share_price.type == :unlimited
            @game.stock_market.move_up(corp)
            @game.stock_market.move_up(corp) if corp.owner.num_shares_of(corp) >= 8
          end

          def sold_out?(corporation)
            return super unless corporation.system?

            # System's treasury share doesn't count against being sold out
            corporation.player_share_holders.values.sum == 90
          end
        end
      end
    end
  end
end
