# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18Uruguay
      module Round
        class Stock < Engine::Round::Stock
          def sold_out_stock_movement(corp)
            return if corp == @game.rptla

            @game.stock_market.move_up(corp)
          end
        end
      end
    end
  end
end
