# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GFrost1831
      module Round
        class Stock < Engine::Round::Stock
          def corporations_to_move_price
            super.reject { |c| c.type == :faction }
          end
        end
      end
    end
  end
end
