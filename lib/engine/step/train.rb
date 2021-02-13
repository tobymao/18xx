# frozen_string_literal: true

require_relative 'base'
require_relative 'emergency_money'

module Engine
  module Step
    module Train
      include EmergencyMoney
      def can_buy_train?(entity = nil, _shell = nil)
        entity ||= current_entity

        can_buy_normal = room?(entity) &&
          buying_power(entity) >= @depot.min_price(entity)

        can_buy_normal || (discountable_trains_allowed?(entity) && @game
          .discountable_trains_for(entity)
          .any? { |_, _, _, price| buying_power(entity) >= price })
      end

      def room?(entity, _shell = nil)
        if @game.class::OBSOLETE_TRAINS_COUNT_FOR_LIMIT
          entity.trains
        else
          entity.trains.reject(&:obsolete)
        end.size < @game.train_limit(entity)
      end

      def must_buy_train?(entity)
        @game.must_buy_train?(entity)
      end

      def president_may_contribute?(entity, _shell = nil)
        must_buy_train?(entity)
      end

      def should_buy_train?(entity); end

      def discountable_trains_allowed?(_entity)
        true
      end

      def buy_train_action(action, entity = nil)
        entity ||= action.entity
        train = action.train
        train.variant = action.variant
        price = action.price
        exchange = action.exchange

        # Check if the train is actually buyable in the current situation
        raise GameError, 'Not a buyable train' unless buyable_train_variants(train, entity).include?(train.variant)
        raise GameError, 'Must pay face value' if must_pay_face_value?(train, entity, price)

        remaining = price - buying_power(entity)
        if remaining.positive? && president_may_contribute?(entity, action.shell)
          cheapest = @depot.min_depot_train
          cheapest_name = name_of_cheapest_variant(cheapest)
          raise GameError, "Cannot purchase #{train.name} train: #{cheapest_name} train available" if
            train.name != cheapest_name &&
            @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST &&
            (!@game.class::EBUY_OTHER_VALUE || train.from_depot?)

          raise GameError, 'Cannot contribute funds when exchanging' if exchange
          raise GameError, 'Cannot buy for more than cost' if price > train.price
          raise GameError, 'Cannot contribute funds when affordable trains exist' if cheapest.price <= entity.cash

          try_take_player_loan(entity.owner, remaining)

          player = entity.owner
          player.spend(remaining, entity)
          @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
        end

        try_take_loan(entity, price)
        @game.queue_log! { @game.phase.buying_train!(entity, train) }

        if exchange
          verb = "exchanges a #{exchange.name} for"
          @depot.reclaim_train(exchange)
        else
          verb = 'buys'
        end

        source = @depot.discarded.include?(train) ? 'The Discard' : train.owner.name

        @log << "#{entity.name} #{verb} a #{train.name} train for "\
          "#{@game.format_currency(price)} from #{source}"

        @game.flush_log!

        @game.buy_train(entity, train, price)
        pass! unless can_buy_train?(entity)
      end

      def can_sell?(entity, bundle)
        return false if @game.class::MUST_SELL_IN_BLOCKS && @corporations_sold.include?(bundle.corporation)
        return false if current_entity != entity && must_issue_before_ebuy?(current_entity)

        super
      end

      def process_sell_shares(action)
        @last_share_sold_price = action.bundle.price_per_share unless action.entity == current_entity
        super
        @corporations_sold << action.bundle.corporation unless action.entity == current_entity
      end

      def needed_cash(_entity)
        @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST ? @depot.min_depot_price : @depot.max_depot_price
      end

      def available_cash(entity)
        return current_entity.cash if entity == current_entity

        entity.cash + current_entity.cash
      end

      def buyable_trains(entity)
        depot_trains = @depot.depot_trains
        other_trains = @depot.other_trains(entity)

        if entity.cash < @depot.min_depot_price
          depot_trains = [@depot.min_depot_train] if @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST

          if @last_share_sold_price
            if @game.class::EBUY_OTHER_VALUE
              other_trains.reject! { |t| t.price < spend_minmax(entity, t).first }
            else
              other_trains = []
            end
          end
        end

        other_trains = [] if entity.cash.zero? && !@game.class::EBUY_OTHER_VALUE

        other_trains.reject! { |t| entity.cash < t.price && must_buy_at_face_value?(t, entity) }

        depot_trains + other_trains
      end

      def buyable_train_variants(train, entity)
        return [] unless buyable_trains(entity).any? { |bt| bt.variants[bt.name] }

        variants = train.variants.values
        return variants if train.owned_by_corporation?

        variants.reject! { |v| entity.cash < v[:price] } if must_issue_before_ebuy?(entity)
        variants
      end

      def setup
        @depot = @game.depot
        @last_share_sold_price = nil
        @last_share_issued_price = nil
        @corporations_sold = []
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

      def must_pay_face_value?(train, entity, price)
        return if train.from_depot? || !must_buy_at_face_value?(train, entity)

        train.price != price
      end

      def must_buy_at_face_value?(train, entity)
        face_value_ability?(entity) || face_value_ability?(train.owner)
      end

      def spend_minmax(entity, train)
        if @game.class::EBUY_OTHER_VALUE && (buying_power(entity) < train.price)
          min = if @last_share_sold_price
                  (buying_power(entity) + entity.owner.cash) - @last_share_sold_price + 1
                else
                  1
                end
          max = [train.price, buying_power(entity) + entity.owner.cash].min
          [min, max]
        else
          [1, buying_power(entity)]
        end
      end

      private

      def face_value_ability?(entity)
        @game.abilities(entity, :train_buy) { |ability| return ability.face_value }
        false
      end

      def name_of_cheapest_variant(train)
        train.variants.min_by { |_, v| v[:price] }.first
      end
    end
  end
end
