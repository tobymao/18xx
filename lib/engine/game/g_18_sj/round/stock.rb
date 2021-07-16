# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18SJ
      module Round
        class Stock < Engine::Round::Stock
          def select_entities
            super.reject { |p| p == @game.edelsward }
          end
        end
      end
    end
  end
end
