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

      def can_sell?(_entity, bundle)
        return false if @game.class::MUST_SELL_IN_BLOCKS && @corporations_sold.include?(bundle.corporation)
        return false if must_issue_before_ebuy?(current_entity)

        super
      end

      def process_sell_shares(action)
        @last_share_sold_price = action.bundle.price_per_share
        super
        @corporations_sold << action.bundle.corporation
        @round.recalculate_order
      end

      def needed_cash(_entity)
        @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST ? @depot.min_depot_price : @depot.max_depot_price
      end

      def available_cash(player)
        player.cash + current_entity.cash
      end

      def buyable_trains(entity)
        depot_trains = @depot.depot_trains
        other_trains = @depot.other_trains(entity)

        if entity.cash < @depot.min_depot_price
          depot_trains = [@depot.min_depot_train] if @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST

          if @last_share_sold_price
            if @game.class::EBUY_OTHER_VALUE
              must_spend = (entity.cash + entity.owner.cash) - @last_share_sold_price + 1
              other_trains.reject! { |t| t.price < must_spend }
            else
              other_trains = []
            end
          end
        end

        depot_trains + other_trains
      end

      def buyable_train_variants(train, entity)
        return [] unless buyable_trains(entity).include?(train)

        variants = train.variants.values

        return variants if train.owned_by_corporation?

        variants.reject! { |v| entity.cash < v[:price] } if must_issue_before_ebuy?(entity)
        variants
      end

      def setup
        @depot = @game.depot
        @last_share_sold_price = nil
        @last_share_issued_price = nil
        @corporations_sold ||= []
      end

      def issuable_shares
        []
      end

      def must_issue_before_ebuy?(corporation)
        @game.class::MUST_EMERGENCY_ISSUE_BEFORE_EBUY &&
          !@last_share_issued_price &&
          @game.emergency_issuable_bundles(corporation).any?
      end

      def ebuy_president_can_contribute?(corporation)
        return false unless corporation.cash < @game.depot.min_depot_price

        !must_issue_before_ebuy?(corporation)
      end
    end
  end
end
