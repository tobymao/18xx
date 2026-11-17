# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GFrost1831
      module Round
        class Stock < Engine::Round::Stock
          # Faction prices only move with Favors and bases
          def corporations_to_move_price
            super.reject { |c| c.type == :faction }
          end
        end
      end
    end
  end
end
