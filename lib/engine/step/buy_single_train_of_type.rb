# frozen_string_literal: true

require_relative 'buy_train'

module Engine
  module Step
    class BuySingleTrainOfType < BuyTrain
      def setup
        super
        @depot_trains_bought = []
      end

      def buyable_trains(entity)
        super.reject { |x| x.from_depot? && @depot_trains_bought.include?(x.sym) }
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
