# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G18Chesapeake
      class Stock < Stock
        def sold_out?(corporation)
          return super unless @game.players.size == 2

          corporation.floated? && corporation.num_market_shares.zero?
        end
      end
    end
  end
end
