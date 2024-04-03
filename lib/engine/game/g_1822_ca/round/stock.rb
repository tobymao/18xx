# frozen_string_literal: true

require_relative '../../g_1822/round/stock'

module Engine
  module Game
    module G1822CA
      module Round
        class Stock < Engine::Game::G1822::Round::Stock
          def sold_out_stock_movement(corp)
            @game.stock_market.move_right(corp)
          end
        end
      end
    end
  end
end
