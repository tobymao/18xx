# frozen_string_literal: true

require_relative 'base'
require_relative 'emergency_money'

module Engine
  module Step
    module Train
      include EmergencyMoney

      attr_accessor :last_share_issued_price, :last_share_sold_price

      def can_buy_train?(entity = nil, _shell = nil)
        entity ||= current_entity

        can_buy_normal = room?(entity) && buying_power(entity) >= @depot.min_price(
            entity, ability: @game.abilities(entity, :train_discount, time: ability_timing)
          )

        can_buy_normal || (discountable_trains_allowed?(entity) && @game
          .discountable_trains_for(entity)
          .any? { |_, _, _, price| buying_power(entity) >= price })
      end

      def ability_timing
        %w[%current_step% buying_train owning_corp_or_turn]
      end

      def room?(entity, _shell = nil)
        if @game.class::OBSOLETE_TRAINS_COUNT_FOR_LIMIT
          entity.trains
        else
          entity.trains.reject(&:obsolete)
        end.size < @game.train_limit(entity)
      end

      def can_entity_buy_train?(entity)
        !entity.minor?
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

      def buy_train_action(action, entity = nil, borrow_from: nil)
        entity ||= action.entity
        train = action.train
        train.variant = action.variant
        price = action.price
        exchange = action.exchange

        # Check if the train is actually buyable in the current situation
        raise GameError, 'Not a buyable train' unless buyable_exchangeable_train_variants(train, entity,
                                                                                          exchange).include?(train.variant)
        raise GameError, 'Must pay face value' if must_pay_face_value?(train, entity, price)
        raise GameError, 'An entity cannot buy a train from itself' if train.owner == entity

        remaining = price - buying_power(entity)
        if remaining.positive? && president_may_contribute?(entity, action.shell)
          check_for_cheapest_train(train)

          raise GameError, 'Cannot contribute funds when exchanging' if exchange
          raise GameError, 'Cannot buy for more than cost' if price > train.price

          try_take_player_loan(entity.owner, remaining)

          player = entity.owner

          if borrow_from && player.cash < remaining
            current_cash = player.cash
            extra_needed = remaining - current_cash
            player.spend(current_cash, entity)
            @log << "#{player.name} contributes #{@game.format_currency(current_cash)}"
            borrow_from.spend(extra_needed, entity)
            @log << "#{borrow_from.name} contributes #{@game.format_currency(extra_needed)}"
          else
            player.spend(remaining, entity)
            @log << "#{player.name} contributes #{@game.format_currency(remaining)}"
          end
        end

        try_take_loan(entity, price)

        if exchange
          verb = "exchanges a #{exchange.name} for"
          @depot.reclaim_train(exchange)
        else
          verb = 'buys'
        end

        source = train.owner
        source_name = @depot.discarded.include?(train) ? 'The Discard' : train.owner.name

        @log << "#{entity.name} #{verb} a #{train.name} train for "\
                "#{@game.format_currency(price)} from #{source_name}"

        @game.buy_train(entity, train, price)
        @game.phase.buying_train!(entity, train, source)
        pass! if !can_buy_train?(entity) && pass_if_cannot_buy_train?(entity)
      end

      def pass_if_cannot_buy_train?(_entity)
        true
      end

      def can_ebuy_sell_shares?(_entity)
        @game.class::EBUY_CAN_SELL_SHARES
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

      def ebuy_offer_only_cheapest_depot_train?
        @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST
      end

      def buyable_trains(entity)
        depot_trains = @depot.depot_trains
        other_trains = @game.class::ALLOW_TRAIN_BUY_FROM_OTHERS ? @depot.other_trains(entity) : []

        if entity.cash < @depot.min_depot_price
          depot_trains = [@depot.min_depot_train] if ebuy_offer_only_cheapest_depot_train?

          if @game.class::EBUY_SELL_MORE_THAN_NEEDED_LIMITS_DEPOT_TRAIN
            # Don't alter the depot train list
            depot_trains = depot_trains.dup
            depot_trains.reject! do |t|
              t.price < spend_minmax(entity, t).first
            end
          end

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

      def buyable_exchangeable_train_variants(train, entity, exchange)
        exchange ? exchangeable_train_variants(train, entity) : buyable_train_variants(train, entity)
      end

      def buyable_train_variants(train, entity)
        return [] unless buyable_trains(entity).any? { |bt| bt.variants[bt.name] }

        train_vatiant_helper(train, entity)
      end

      def exchangeable_train_variants(train, entity)
        discount_info = @game.discountable_trains_for(entity)
        return [] unless discount_info.any? { |_, discount_train, _, _| discount_train.variants[discount_train.name] }

        train_vatiant_helper(train, entity)
      end

      def train_vatiant_helper(train, entity)
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

      def check_for_cheapest_train(train)
        cheapest = @depot.min_depot_train
        cheapest_names = names_of_cheapest_variants(cheapest)
        raise GameError, "Cannot purchase #{train.name} train: cheaper train available (#{cheapest_names.first})" if
          !cheapest_names.include?(train.name) &&
          @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST &&
          (!@game.class::EBUY_OTHER_VALUE || train.from_depot?)
      end

      def names_of_cheapest_variants(train)
        train.variants.group_by { |_, v| v[:price] }.min_by { |k, _| k }.last.flat_map(&:first)
      end
    end
  end
end
