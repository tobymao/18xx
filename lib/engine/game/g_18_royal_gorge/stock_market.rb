# frozen_string_literal: true

require_relative '../../stock_market'

module Engine
  module Game
    module G18RoyalGorge
      class StockMarket < Engine::StockMarket
        def move(corporation, coordinates, force: false)
          share_price = share_price(coordinates)
          return unless share_price
          return if share_price == corporation.share_price
          return if !force && !share_price.normal_movement?

          corporation.share_price.corporations.delete(corporation)
          corporation.share_price = share_price
          share_price.corporations << corporation
          @max_reached = true if corporation.type == :rail && share_price.end_game_trigger?
        end
      end
    end
  end
end
