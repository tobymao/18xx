# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18Rhl
      module Round
        class Stock < Engine::Round::Stock
          def finish_round
            @game.handle_share_price_increase_for_newly_floated_corporations
            super
          end
        end
      end
    end
  end
end
