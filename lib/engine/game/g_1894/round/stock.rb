# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1894
      module Round
        class Stock < Engine::Round::Stock
          protected

          def sold_out_stock_movement(corp)
            @game.stock_market.move_up(corp) if corp.share_price.type == :unlimited
            @game.stock_market.move_up(corp)
            @game.stock_market.move_up(corp) if corp.owner.num_shares_of(corp) >= 8
          end

          def sold_out?(corporation)
            corporation.player_share_holders.values.sum + corporation.reserved_shares.sum(&:percent) == 100
          end
        end
      end
    end
  end
end
