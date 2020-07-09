# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Train < Base
      def actions(entity)
        # TODO: This needs to check it actually needs to sell shares.
        return ['sell_shares'] if entity == current_entity.owner
        return [] if entity != current_entity
        # TODO: Not sure this is right
        return %w[sell_shares buy_train] if must_buy_train?(entity)
        return ['buy_train'] if must_buy_train?(entity)
        return %w[buy_train pass] if can_buy_train?(entity)

        []
      end

      def sequential?
        true
      end

      def can_buy_train?(entity = nil)
        entity ||= current_entity
        can_buy_normal = has_room?(entity) &&
          entity.cash >= @depot.min_price(entity)

        can_buy_normal || @depot
          .discountable_trains_for(entity)
          .any? { |_, _, price| entity.cash >= price }
      end

      def has_room?(entity)
        entity.trains.reject(&:obsolete).size < @game.phase.train_limit
      end

      def must_buy_train?(entity)
        !entity.rusted_self && entity.trains.empty? && @game.graph.route?(entity)
      end

      def process_buy_train(action)
        entity = action.entity
        train = action.train
        price = action.price
        exchange = action.exchange
        # Check if the train is actually buyable in the current situation
        raise GameError, 'Not a buyable train' unless buyable_trains.include?(train)

        remaining = price - entity.cash
        if remaining.positive? && must_buy_train?(entity)
          cheapest = @depot.min_depot_train
          if train != cheapest && (!@ebuy_other_value || train.from_depot?)
            raise GameError, "Cannot purchase #{train.name} train: #{cheapest.name} train available"
          end
          raise GameError, 'Cannot contribute funds when exchanging' if exchange
          raise GameError, 'Cannot buy for more than cost' if price > train.price

          player = entity.owner
          player.spend(remaining, entity)
          @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
        end

        if exchange
          verb = "exchanges a #{exchange.name} for"
          @depot.reclaim_train(exchange)
        else
          verb = 'buys'
        end

        source = @depot.discarded.include?(train) ? 'The Discard' : train.owner.name

        @log << "#{entity.name} #{verb} a #{train.name} train for "\
          "#{@game.format_currency(price)} from #{source}"
        entity.buy_train(train, price)
      end

      def process_sell_shares(action)
        raise GameError, "Cannot sell shares of #{action.bundle.corporation.name}" unless can_sell?(action.bundle)

        @last_share_sold_price = action.bundle.price_per_share
        @game.sell_shares_and_change_price(action.bundle)
        @round.recalculate_order
      end

      def can_sell?(bundle)
        player = bundle.owner
        # Can't sell president's share
        return false unless bundle.can_dump?(player)

        # Can only sell as much as you need to afford the train
        total_cash = bundle.price + player.cash + current_entity.cash
        return false if total_cash >= @depot.min_depot_price + bundle.price_per_share

        # Can't swap presidency
        corporation = bundle.corporation
        if corporation.president?(player) &&
            (!@game.class::EBUY_PRES_SWAP || corporation == current_entity)
          share_holders = corporation.share_holders
          remaining = share_holders[player] - bundle.percent
          next_highest = share_holders.reject { |k, _| k == player }.values.max || 0
          return false if remaining < next_highest
        end

        # Can't oversaturate the market
        return false unless @game.share_pool.fit_in_bank?(bundle)

        # Otherwise we're good
        true
      end

      def buyable_trains
        depot_trains = @depot.depot_trains
        other_trains = @depot.other_trains(current_entity)

        # If the corporation cannot buy a train, then it can only buy the cheapest available
        min_depot_train = @depot.min_depot_train
        if min_depot_train.price > current_entity.cash
          depot_trains = [min_depot_train]

          if @last_share_sold_price
            # 1889, a player cannot contribute to buy a train from another corporation
            return depot_trains unless @game.class::EBUY_OTHER_VALUE

            # 18Chesapeake and most others, it's legal to buy trains from other corps until
            # if the player has just sold a share they can buy a train between cash-price_last_share_sold and cash
            # e.g. If you had $40 cash, and if the train costs $100 and you've sold a share for $80,
            # you now have $120 cash the $100 train should still be available to buy
            min_available_cash = (current_entity.cash + current_entity.owner.cash) - @last_share_sold_price
            return depot_trains + (other_trains.reject { |x| x.price < min_available_cash })
          end
        end
        depot_trains + other_trains
      end

      def setup
        @depot = @game.depot
        @last_share_sold_price = nil
      end
    end
  end
end
