# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        def actions(entity)
          return ['bid', 'pass'] if @bid

          actions = super
          actions << 'bid' # if can bid
          actions
        end

        def active_entities
          return super unless @bid

          entities = @round.entities
          [entities[entities.index(@bid.entity) + 1 % entities.size]]
        end

        def process_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          unless @bid
            @log << "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
            @game.place_home_token(action.corporation)
          else
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
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
          return 100 unless @bid

          @bid.price + min_increment
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

        def auctioning_corporation
          @bid&.corporation
        end
      end
    end
  end
end
