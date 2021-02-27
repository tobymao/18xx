# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1893
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            return false if corporation == @game.adsk

            super
          end
        end
      end
    end
  end
end
