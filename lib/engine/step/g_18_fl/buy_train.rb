# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G18FL
      class BuyTrain < BuyTrain
        def buyable_trains(entity)
          # Trainbuying in 18FL is like 1836 except 6/3E trains are exempt
          # Both the 6 and 3E have the '6' name because 3E is a variant
          super.reject { |x| x.from_depot? && @depot_trains_bought.include?(x.sym) && x.name != '6' }
        end

        def setup
          super
          @depot_trains_bought = []
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
