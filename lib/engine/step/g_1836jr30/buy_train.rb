# frozen_string_literal: true

require_relative '../buy_train'

module Engine
  module Step
    module G1836Jr30
      class BuyTrain < BuyTrain
        def buyable_trains
          super.reject { |x| x.from_depot? && @depot_trains_bought.include?(x.sym) }
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

          pass! unless buyable_trains.any?
        end
      end
    end
  end
end
