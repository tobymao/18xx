# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18Norway
      module Round
        class Stock < Engine::Round::Stock
          def corporations_to_move_price
            @game.corporations.select(&:floated?)
          end
        end
      end
    end
  end
end
