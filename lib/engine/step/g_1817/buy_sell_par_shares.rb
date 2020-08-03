# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1817
      class BuySellParShares < BuySellParShares
        def actions(entity)
          return ['bid', 'pass'] if @bid

          actions = super
          actions |= ['bid', 'pass']
          actions
        end

        def active_entities
          return super unless @bid

          [@bidders[(@bidders.index(@bid.entity) + 1) % @bidders.size]]
        end

        def pass!
          return super unless @bid

          @bidders.delete(current_entity)
          finalize_auction
        end

        def process_bid(action)
          entity = action.entity
          corporation = action.corporation
          price = action.price

          unless @bid
            @log << "#{entity.name} auctions #{corporation.name} for #{@game.format_currency(price)}"
            @game.place_home_token(action.corporation)
            @current_actions << action
          else
            @log << "#{entity.name} bids #{@game.format_currency(price)} for #{corporation.name}"
          end

          @bid = action
          @bidders = @round.entities.select do |player|
            player == entity || player.cash >= min_bid(corporation) # also need to add company trade in
          end
        end

        def finalize_auction
          return if @bidders.size < 2

          price = @bid.price / 2

          share_price = @game
            .stock_market
            .market[0]
            .reverse
            .find { |share_price| share_price.price < price }

          process_par(Action::Par.new(@bid.entity, corporation: @bid.corporation, share_price: share_price))
          @bid = nil
          @bidders = nil
          pass!
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
          @bid ||= nil
        end

        def auctioning_corporation
          @bid&.corporation
        end
      end
    end
  end
end
