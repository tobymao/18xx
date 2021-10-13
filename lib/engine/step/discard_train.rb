# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class DiscardTrain < Base
      ACTIONS = %w[discard_train].freeze

      def actions(entity)
        return [] unless crowded_corps.include?(entity)

        ACTIONS
      end

      def active_entities
        crowded_corps.take(1)
      end

      def active?
        !crowded_corps.empty?
      end

      def description
        'Discard Train'
      end

      def process_discard_train(action)
        train = action.train
        @game.depot.reclaim_train(train)
        @log << "#{action.entity.name} discards #{train.name}"
      end

      def crowded_corps
        @game.crowded_corps
      end

      def trains(corporation)
        corporation.trains
      end
    end
  end
end
