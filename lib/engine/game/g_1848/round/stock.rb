# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1848
      module Round
        class Stock < Engine::Round::Stock
          def sold_out_stock_movement(corp)
            super if corp != @game.boe
          end
        end
      end
    end
  end
end
