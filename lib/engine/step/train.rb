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
          @game.buying_power(entity) >= @depot.min_price(entity)

        can_buy_normal || @depot
          .discountable_trains_for(entity)
          .any? { |_, _, price| @game.buying_power(entity) >= price }
      end

      def room?(entity)
        if @game.class::OBSOLETE_TRAINS_COUNT_FOR_LIMIT
          entity.trains
        else
          entity.trains.reject(&:obsolete)
        end.size < @game.phase.train_limit(entity)
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

        @game.queue_log! { @game.phase.buying_train!(entity, train) }

        # Check if the train is actually buyable in the current situation
        @game.game_error('Not a buyable train') unless buyable_train_variants(train, entity).include?(train.variant)
        @game.game_error('Must pay face value') if must_pay_face_value?(train, entity, price)

        remaining = price - entity.cash
        if remaining.positive? && must_buy_train?(entity)
          cheapest = @depot.min_depot_train
          @game.game_error("Cannot purchase #{train.name} train: #{cheapest.name} train available") if
            train != cheapest &&
            @game.class::EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST &&
            (!@game.class::EBUY_OTHER_VALUE || train.from_depot?)

          @game.game_error('Cannot contribute funds when exchanging') if exchange
          @game.game_error('Cannot buy for more than cost') if price > train.price
          @game.game_error('Cannot contribute funds when affordable trains exist') if cheapest.price <= entity.cash

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

        @game.flush_log!

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
        @corporations_sold = []
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

      def must_pay_face_value?(train, entity, price)
        return if train.from_depot? || !must_buy_at_face_value?(train, entity)

        train.price != price
      end

      def must_buy_at_face_value?(train, entity)
        face_value_ability?(entity) || face_value_ability?(train.owner)
      end

      def spend_minmax(entity, train)
        if @game.class::EBUY_OTHER_VALUE && (entity.cash < train.price)
          min = if @last_share_sold_price
                  (entity.cash + entity.owner.cash) - @last_share_sold_price + 1
                else
                  1
                end
          max = [train.price, entity.cash + entity.owner.cash].min
          [min, max]
        else
          [1, entity.cash]
        end
      end

      private

      def face_value_ability?(entity)
        entity.abilities(:train_buy) { |ability| return ability.face_value }
        false
      end
    end
  end
end
