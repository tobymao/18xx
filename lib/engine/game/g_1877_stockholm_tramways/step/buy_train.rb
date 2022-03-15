# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G1877StockholmTramways
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def actions(entity)
            return [] if entity != current_entity || buyable_trains(entity).empty?
            return %w[buy_train] if must_buy_train?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def pass!
            if current_entity.trains.empty?
              all_cash = buying_power(current_entity.owner)
              current_entity.owner.spend(all_cash, current_entity)
              @log << "#{current_entity.owner.name} contributes #{@game.format_currency(all_cash)}"
            end
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
            entity.trains.empty? && buying_power(entity) + buying_power(entity.owner) >= @depot.min_depot_price
          end

          def should_buy_train?(entity)
            :contribute_all if entity.trains.empty? && buying_power(entity) + buying_power(entity.owner) < @depot.min_depot_price
          end

          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            depot_trains = [] if buying_power(entity) < @depot.min_depot_price &&
              (entity.trains.any? || buying_power(entity) + buying_power(entity.owner) < @depot.min_depot_price)

            other_trains = @depot.other_trains(entity).select do |train|
              entity.owner == train.owner.owner && (buying_power(entity) >= train_price_min(train) ||
                (entity.trains.empty? && buying_power(entity) + buying_power(entity.owner) >= train_price_min(train)))
            end

            depot_trains + other_trains
          end

          def spend_minmax(entity, train)
            if buying_power(entity) >= train_price_min(train)
              [train_price_min(train), buying_power(entity)]
            else
              [train_price_min(train), train_price_min(train)]
            end
          end

          def train_price_min(train)
            (train.price / 25).ceil * 5
          end

          def president_may_contribute?(entity)
            entity.trains.empty?
          end

          def can_ebuy_sell_shares?(_)
            false
          end
        end
      end
    end
  end
end
