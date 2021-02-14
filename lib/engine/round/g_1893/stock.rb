# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1893
      class Stock < Stock
        def sold_out?(corporation)
          return false if corporation == @game.adsk

          super
        end
      end
    end
  end
end
