# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G1847AE
      class StockMarket < Engine::StockMarket
        attr_writer :game

        def move_up(corporation)
          return if corporation == @game.lfk

          super
        end
      end
    end
  end
end
