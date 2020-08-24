# frozen_string_literal: true

require_relative 'buy_train'

module Engine
  module Step
    class SingleDepotTrainBuyBeforePhase4 < BuyTrain
      STATUS_TEXT = {
        'limited_train_buy' => ['Limited Train Buy', 'Corporations can only buy one train from the bank per OR'],
      }.freeze

      def buyable_trains(entity)
        super.reject do |train|
          train.from_depot? &&
            !@game.phase.available?('4') &&
            @round.bought_trains.include?(entity)
        end
      end

      def process_buy_train(action)
        from_depot = action.train.from_depot?
        super
        return unless from_depot

        entity = action.entity
        @round.bought_trains << entity
        pass! unless buyable_trains(entity).any?
      end

      def round_state
        { bought_trains: [] }
      end
    end
  end
end
