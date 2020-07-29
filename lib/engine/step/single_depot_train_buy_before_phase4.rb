# frozen_string_literal: true

require_relative 'buy_train'

module Engine
  module Step
    class SingleDepotTrainBuyBeforePhase4 < BuyTrain
      def buyable_trains
        super.reject { |x| x.from_depot? && !@game.phase.available?('4') && already_bought_from_depot? }
      end

      def process_buy_train(action)
        from_depot = action.train.from_depot?
        super
        return unless from_depot

        @round.trains_bought << {
          entity: action.entity,
        }
        pass! unless buyable_trains.any?
      end

      private

      def already_bought_from_depot?
        @round.trains_bought.find { |e| e[:entity].name == current_entity.name }
      end
    end
  end
end
