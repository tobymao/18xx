# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1824
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def can_entity_buy_train?(_entity)
            true
          end

          def must_buy_train?(entity)
            # Rule VII.11 all entities must own a train, unless coal company and there are no g-trains in the depot
            return false unless entity.trains.empty?
            return true unless @game.coal_railway?(entity)

            depot_g_trains = @depot.depot_trains.select { |t| @game.goods_train?(t.name) }
            depot_g_trains.any?
          end

          def pass_if_cannot_buy_train?(_entity)
            false
          end

          def must_take_player_loan?(entity)
            @game.depot.min_depot_price > (entity.cash + entity.owner.cash)
          end

          def try_take_player_loan(entity, cost)
            return unless cost > entity.cash

            @game.take_loan(entity, cost - entity.cash)
          end

          def process_buy_train(action)
            entity ||= action.entity
            train = action.train

            if entity&.corporation? && !@game.goods_train?(train.name) && @game.coal_railway?(entity)
              raise GameError, 'Coal railways can only own g-trains'
            end

            @game.two_train_bought = true if train.name == '2'

            super
          end

          def buyable_trains(entity)
            trains = super
            is_coal_company = @game.coal_railway?(entity)

            # Coal railways may only buy g-trains, other corporations may buy any
            trains.reject! { |t| is_coal_company && !@game.goods_train?(t.name) }

            # Cannot buy g-trains until first 2 train has been bought
            trains.reject! { |t| @game.goods_train?(t.name) && !@game.two_train_bought }

            trains.select!(&:from_depot?) unless @game.can_buy_train_from_others?

            trains
          end
        end
      end
    end
  end
end
