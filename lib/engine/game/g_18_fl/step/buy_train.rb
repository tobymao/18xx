# frozen_string_literal: true

require_relative '../../../step/buy_train'

module Engine
  module Game
    module G18FL
      module Step
        class BuyTrain < Engine::Step::BuyTrain
          def buyable_trains(entity)
            depot_trains = @depot.depot_trains
            other_trains = @depot.other_trains(entity)

            if entity.cash < (@depot.min_depot_price) && @last_share_sold_price
              other_trains.reject! { |t| t.price < spend_minmax(entity, t).first }
            end

            # A corp with zero cash may buy trains from other corps if and only if the president sells no shares.
            other_trains = [] if entity.cash.zero? && @last_share_sold_price

            other_trains.reject! { |t| entity.cash < t.price && must_buy_at_face_value?(t, entity) }

            # Trainbuying in 18FL is like 1836 except 6/3E trains are exempt
            # Both the 6 and 3E have the '6' name because 3E is a variant
            other_trains + (depot_trains.reject { |x| @depot_trains_bought.include?(x.sym) && x.name != '6' })
          end

          def setup
            super
            @depot_trains_bought = []
          end

          def spend_minmax(entity, train)
            if entity.cash.zero? && (buying_power(entity) < train.price)
              [1, [train.price, buying_power(entity) + entity.owner.cash].min]
            else
              [1, buying_power(entity)]
            end
          end

          def process_buy_train(action)
            # Since the train won't be in the depot after being bought store the state now.
            from_depot = action.train.from_depot?
            super

            return unless from_depot

            @depot_trains_bought << action.train.sym

            pass! if buyable_trains(action.entity).empty?
          end
        end
      end
    end
  end
end
