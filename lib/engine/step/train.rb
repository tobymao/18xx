# frozen_string_literal: true

require_relative 'base'
require_relative 'emergency_money'

module Engine
  module Step
    module Train
      include EmergencyMoney
      def can_buy_train?(entity = nil)
        entity ||= current_entity
        can_buy_normal = room?(entity) &&
          entity.cash >= @depot.min_price(entity)

        can_buy_normal || @depot
          .discountable_trains_for(entity)
          .any? { |_, _, price| entity.cash >= price }
      end

      def room?(entity)
        entity.trains.reject(&:obsolete).size < @game.phase.train_limit
      end

      def must_buy_train?(entity)
        @game.must_buy_train?(entity)
      end

      def should_buy_train?(entity); end

      def buy_train_action(action, entity = nil)
        entity ||= action.entity
        train = action.train
        train.variant = action.variant
        price = action.price
        exchange = action.exchange
        @game.phase.buying_train!(entity, train)

        # Check if the train is actually buyable in the current situation
        @game.game_error('Not a buyable train') unless buyable_train_variants(train, entity).include?(train.variant)

        remaining = price - entity.cash
        if remaining.positive? && must_buy_train?(entity)
          cheapest = @depot.min_depot_train
          if train != cheapest && (!@game.class::EBUY_OTHER_VALUE || train.from_depot?)
            @game.game_error("Cannot purchase #{train.name} train: #{cheapest.name} train available")
          end
          @game.game_error('Cannot contribute funds when exchanging') if exchange
          @game.game_error('Cannot buy for more than cost') if price > train.price

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
        pass! unless can_buy_train?(entity)
      end

      def process_sell_shares(action)
        super

        @last_share_sold_price = action.bundle.price_per_share
        @round.recalculate_order
      end

      def needed_cash(_entity)
        @depot.min_depot_price
      end

      def available_cash(player)
        player.cash + current_entity.cash
      end

      def buyable_trains(entity)
        depot_trains = @depot.depot_trains
        other_trains = @depot.other_trains(entity)
        # If the corporation cannot buy a train, then it can only buy the cheapest available (if there is any...)
        min_depot_train = @depot.min_depot_train
        if min_depot_train && min_depot_train.price > entity.cash

          depot_trains = [min_depot_train] if @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST

          if @last_share_sold_price
            # 1889, a player cannot contribute to buy a train from another corporation
            return depot_trains unless @game.class::EBUY_OTHER_VALUE

            # 18Chesapeake and most others, it's legal to buy trains from other corps until
            # if the player has just sold a share they can buy a train between cash-price_last_share_sold and cash
            # e.g. If you had $40 cash, and if the train costs $100 and you've sold a share for $80,
            # you now have $120 cash the $100 train should still be available to buy
            min_available_cash = (entity.cash + entity.owner.cash) - @last_share_sold_price
            return depot_trains + (other_trains.reject { |x| x.price < min_available_cash })
          end
        end
        depot_trains + other_trains
      end

      def buyable_train_variants(train, entity)
        buyable_trains(entity).include?(train) ? train.variants.values : []
      end

      def setup
        @depot = @game.depot
        @last_share_sold_price = nil
      end

      def issuable_shares
        []
      end
    end
  end
end
