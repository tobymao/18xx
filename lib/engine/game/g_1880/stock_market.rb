# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G1880
      class StockMarket < Engine::StockMarket
        attr_writer :game

        def move_right(corporation)
          return if @game.communism

          super
        end

        def move_up(corporation)
          return if @game.communism

          super
        end

        def move_down(corporation)
          return if @game.communism

          super
        end

        def move_left(corporation)
          return if @game.communism

          super
        end
      end
    end
  end
end
