# frozen_string_literal: true

require_relative '../train'

module Engine
  module Step
    class SingleDepotTrainBuyBeforePhase4 < Train
      def buyable_trains
        super.reject { |x| x.from_depot? && @depot_trains_bought.any? && !@game.phase.available?('4') }
      end

      def setup
        super
        @depot_trains_bought = []
      end

      def unpass!
        super
        setup
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
