# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1880Romania
      module Round
        class Stock < G1880::Round::Stock
          def finish_round
            @game.add_interest_player_loans!
            super
          end
        end
      end
    end
  end
end
