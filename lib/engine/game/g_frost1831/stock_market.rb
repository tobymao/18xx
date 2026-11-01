# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module GFrost1831
      class StockMarket < Engine::StockMarket
        # The first corporation to reach a unique-bonus (Influence) cell claims it;
        # drop the type so later arrivals don't get the bonus again.
        def consume_unique_bonus(price)
          price.types.delete(:pays_unique_bonus)
        end
      end
    end
  end
end
