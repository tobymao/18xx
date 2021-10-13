# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1840
      module Round
        class Stock < Engine::Round::Stock
          def corporations_to_move_price
            @game.corporations.select { |item| item.floated? && item.type != :minor }
          end
        end
      end
    end
  end
end
