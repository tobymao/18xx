# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        def actions(entity)
          actions = super
          actions << 'bid' # if can bid
          # actions << 'place_home_token' if @bid
          actions
        end

        def process_bid(action)
          entity = action.entity

          unless @bid
            @log << "#{entity.name} auctions #{action.corporation.name} for #{@game.format_currency(action.price)}"
            @game.place_home_token(action.corporation)
          end

          @bid = action
        end

        def committed_cash
          0
        end

        def min_increment
          5
        end

        def min_bid(_corporation)
          100
        end

        def max_bid(player, _corporation)
          [400, player.cash].min
        end

        def can_ipo_any?(entity)
          false
        end

        def setup
          super
          @bid = nil
        end
      end
    end
  end
end
