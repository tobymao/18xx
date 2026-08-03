# lib/engine/game/g_1835/round/stock.rb
# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1835
      module Round
        class Stock < Engine::Round::Stock
          def setup
            @game.conversion_choice_during_or = false
            super
          end
        end
      end
    end
  end
end
