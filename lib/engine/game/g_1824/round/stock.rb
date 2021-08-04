# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1824
      module Round
        class Stock < Engine::Round::Stock
          def finish_round
            @game.corporations.select(&:floated?).sort.each do |corp|
              prev = corp.share_price.price
              sold_out_stock_movement(corp) if sold_out?(corp)
              @game.log_share_price(corp, prev)
            end
          end
        end
      end
    end
  end
end
