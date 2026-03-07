# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1824
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def round_state
            super.merge(
              {
                train_exchanged_by_entity: [],
                shares_sold_by_owner: [],
              }
            )
          end

          def actions(entity)
            actions = super.clone

            # Skip train buy if there are no trains to buy - this was needed as the super implementation
            # resulted in Buy Train / Pass when coal company had no g-trains to buy
            if entity.operator? && can_entity_buy_train?(entity) && !must_buy_train?(entity) && buyable_trains(entity).empty?
              actions.delete('pass')
              actions.delete('buy_train')
            end

            actions
          end

          def can_entity_buy_train?(entity)
            !entity.receivership?
          end

          def must_buy_train?(entity)
            return false if entity.receivership?

            # Rule VII.11 all entities must own a train, unless coal company and there are no g-trains in the depot
            return false unless entity.trains.empty?

            return true unless @game.coal_railway?(entity)

            depot_g_trains = @depot.depot_trains.select { |t| @game.goods_train?(t.name) }
            !depot_g_trains.empty?
          end

          def president_may_contribute?(entity, _shell = nil)
            must_buy_train?(entity)
          end

          def can_ebuy_sell_shares?(entity)
            owner = entity.owner
            available_cash = entity.cash + owner.cash

            cheapest = cheapest_train_price(entity)
            return false if entity.cash >= cheapest

            available_cash < most_expensive_train_price(entity)
          end

          def process_sell_shares(action)
            check_excessive_selling_of_shares_to_by_most_expensive(action)

            # Store price of one share, to be used to stop some rule breaking actions
            @round.shares_sold_by_owner << action.bundle.price_per_share

            super
          end

          def check_excessive_selling_of_shares_to_by_most_expensive(action)
            # Disallow selling if bundle larger than needed to afford most expensive depot train
            bundle_with_one_less = action.bundle.price - action.bundle.price_per_share
            available_cash = current_entity.cash + action.entity.cash
            most_expensive = most_expensive_train_price(current_entity)

            return if bundle_with_one_less + available_cash < most_expensive

            raise GameError, 'Cannot sell more shares than needed to buy the most expensive available train'
          end

          def pass_if_cannot_buy_train?(_entity)
            false
          end

          def cheapest_train_price(corporation)
            candidates_in_depot = buyable_depot_trains(corporation)
            return candidates_in_depot.map(&:price).min unless candidates_in_depot.empty?

            0
          end

          def most_expensive_train_price(corporation)
            candidates_in_depot = buyable_depot_trains(corporation)
            return candidates_in_depot.map(&:price).max unless candidates_in_depot.empty?

            0
          end

          def buyable_depot_trains(corporation)
            candidates = buyable_trains(corporation)
            candidates.select(&:from_depot?)
          end

          def must_take_player_loan?(entity)
            @game.depot.min_depot_price > (entity.cash + entity.owner.cash)
          end

          def process_buy_train(action)
            entity ||= action.entity
            train = action.train
            if action.exchange
              raise GameError, "#{entity.name} has already exchanged trains this OR" unless discountable_trains_allowed?(entity)

              @round.train_exchanged_by_entity << entity.id
            end

            if entity&.corporation? && !@game.goods_train?(train.name) && @game.coal_railway?(entity)
              raise GameError, 'Coal railways can only own g-trains'
            end

            ensure_no_buy_train_after_selling_share(action)

            ensure_excessive_seeling_not_done_to_buy_cheaper_train(action)

            super

            @game.two_train_bought = true if train.name == '2'
          end

          def ensure_no_buy_train_after_selling_share(action)
            return if @round.shares_sold_by_owner.empty?
            return if action.train.from_depot?

            # During emegency financing we may not buy cross-over train if we have sold shares
            raise GameError, 'Cannot buy train from other corporation if sold shares during emergency financing'
          end

          def ensure_excessive_seeling_not_done_to_buy_cheaper_train(action)
            return if @round.shares_sold_by_owner.empty?
            return unless action.train.from_depot?

            # During emegency financing we may not sell more shares when needed to buy a train. We are allowed
            # to sell shares to buy a more expensive one, but we may not sell more than needed to buy a train.
            cheapest_share = @round.shares_sold_by_owner.min
            available_cash = action.entity.cash + action.entity.owner.cash
            return if available_cash - cheapest_share < action.price

            raise GameError, 'Cannot sell more shares than needed to buy a depot train'
          end

          def buyable_trains(entity)
            trains = super

            # Coal railways may only buy g-trains, other corporations may buy any
            trains.reject! { |t| @game.coal_railway?(entity) && !@game.goods_train?(t.name) }

            # Cannot buy g-trains until first 2 train has been bought
            trains.reject! { |t| @game.goods_train?(t.name) && !@game.two_train_bought }

            trains.select!(&:from_depot?) unless @game.can_buy_train_from_others?

            trains
          end

          def spend_minmax(entity, train)
            # Rule VII.11, bullet 8: Face price must be paid if buying from another player's corporation
            return [train.price, train.price] if train.owner&.corporation? && train.owner.owner != entity.owner

            super
          end

          def discountable_trains_allowed?(entity)
            !@round.train_exchanged_by_entity.include?(entity.id)
          end
        end
      end
    end
  end
end
