# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1854
      module Round
        class Stock < Engine::Round::Stock
          def sold_out_stock_movement(corp)
            @game.stock_market.move_up_right_hex(corp)
            @game.possibly_convert(corp)
          end
        end
      end
    end
  end
end
