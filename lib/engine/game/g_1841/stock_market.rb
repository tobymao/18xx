# frozen_string_literal: true

module Engine
  module Game
    module G1841
      class StockMarket < Engine::StockMarket
        def initialize(market, unlimited_types, multiple_buy_types: [], zigzag: nil, ledge_movement: nil, game: nil)
          @game = game
          super(market, unlimited_types, multiple_buy_types: multiple_buy_types, zigzag: zigzag, ledge_movement: ledge_movement)
        end

        def right(corporation, coordinates)
          if (corporation&.type == :minor && corporation&.share_price&.types&.include?(:max_price)) ||
              (@game.phase.name.to_i < 8 && corporation&.share_price&.types&.include?(:max_price_1))
            up(corporation, coordinates)
          else
            super
          end
        end
      end
    end
  end
end
