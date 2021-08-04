# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18Chesapeake
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            return super unless @game.two_player?

            corporation.floated? && corporation.num_market_shares.zero?
          end
        end
      end
    end
  end
end
