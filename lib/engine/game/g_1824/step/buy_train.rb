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
              }
            )
          end

          def actions(entity)
            actions = super.clone
            return actions unless entity.operator?

            # Skip train buy if there are no trains to buy - this was needed as the super implementation
            # resulted in Buy Train / Pass when coal company had no g-trains to buy
            if can_entity_buy_train?(entity) && !must_buy_train?(entity) && buyable_trains(entity).empty?
              actions.delete('pass')
              actions.delete('buy_train')
            end

            actions
          end

          def can_entity_buy_train?(entity)
            return false if entity.receivership?

            entity.operator?
          end

          def must_buy_train?(entity)
            return false if entity.receivership?

            # Rule VII.11 all entities must own a train, unless coal company and there are no g-trains in the depot
            return false unless entity.trains.empty?

            return true unless @game.coal_railway?(entity)

            depot_g_trains = @depot.depot_trains.select { |t| @game.goods_train?(t.name) }
            !depot_g_trains.empty?
          end

          def pass_if_cannot_buy_train?(_entity)
            false
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

            super

            @game.two_train_bought = true if train.name == '2'
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
