# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1860
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity.receivership? && entity.trains.any?
            return [] if entity != current_entity || buyable_trains(entity).empty?
            return [] if @game.bankrupt?(entity) || entity.share_price&.type == :close
            return %w[buy_train] if must_buy_train?(entity)

            super
          end

          def process_buy_train(action)
            if action.train.owned_by_corporation?
              min, max = spend_minmax(action.entity, action.train)
              unless (min..max).cover?(action.price)
                raise GameError, "#{action.entity.name} may not spend "\
                                 "#{@game.format_currency(action.price)} on "\
                                 "#{action.train.owner.name}'s #{action.train.name} "\
                                 'train; may only spend between '\
                                 "#{@game.format_currency(min)} and "\
                                 "#{@game.format_currency(max)}."
              end
              unless (action.price % @game.class::TRAIN_PRICE_MULTIPLE).zero?
                raise GameError, 'Train purchase price must be a multiple of '\
                                 "#{@game.format_currency(@game.class::TRAIN_PRICE_MULTIPLE)}"
              end
            end

            buy_train_action(action)
            pass! unless can_buy_train?(action.entity)
          end

          def must_buy_train?(entity)
            entity.trains.empty? &&
              !@game.bankrupt?(entity) &&
              @game.depot.min_depot_price.positive? &&
              entity.cash > @game.depot.min_depot_price
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            other_trains = @depot.other_trains(entity)

            depot_trains = [] if entity.cash < @depot.min_depot_price

            other_trains = [] if entity.cash < @game.class::TRAIN_PRICE_MIN || @game.nationalization

            other_trains.reject! { |t| illegal_train_buy?(entity, t) }

            depot_trains + other_trains
          end

          def president_may_contribute?(_entity, _shell = nil)
            false
          end

          def illegal_train_buy?(entity, train)
            @game.bankrupt?(train.owner) ||
              entity.receivership? ||
              train.owner.receivership? ||
              (!entity.trains.empty? && train.owner.trains.size < 2)
          end

          def spend_minmax(entity, _train)
            [@game.class::TRAIN_PRICE_MIN, buying_power(entity)]
          end
        end
      end
    end
  end
end
