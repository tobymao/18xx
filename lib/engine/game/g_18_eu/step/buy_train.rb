# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18EU
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          # This is necessary because base code assumes minors cannot purchase trains.
          # That shouldn't be base, imo, but requires a refactor.
          def actions(entity)
            return ['sell_shares'] if entity == current_entity.owner

            return [] if entity != current_entity

            return %w[sell_shares buy_train] if president_may_contribute?(entity)
            return %w[buy_train pass] if can_buy_train?(entity)

            []
          end

          def buyable_trains(entity)
            depot_trains = @game.depot_trains(entity)

            if entity.cash < @game.min_depot_price(entity) && ebuy_offer_only_cheapest_depot_train?
              depot_trains = [@game.min_depot_train(entity)]
            end

            # if a player sold shares, they cannot buy over
            other_trains = if @last_share_sold_price && entity.cash.zero?
                             []
                           else
                             @depot.other_trains(entity).reject { |t| @game.pullman?(t) }
                           end

            depot_trains + other_trains
          end

          def cheapest_train_price(corporation)
            @game.min_depot_price(corporation)
          end

          def check_for_cheapest_train(_train)
            true
          end

          def needed_cash(_entity)
            cheapest_train_price(current_entity)
          end
        end
      end
    end
  end
end
