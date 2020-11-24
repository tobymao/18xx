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
        [crowded_corps&.first].compact
      end

      def active?
        crowded_corps.any?
      end

      def description
        'Discard Train'
      end

      def process_discard_train(action)
        train = action.train
        @game.depot.reclaim_train(train)
        @log.action! "discards #{train.name}"
      end

      def crowded_corps
        @game.corporations.select do |c|
          if @game.class::OBSOLETE_TRAINS_COUNT_FOR_LIMIT
            c.trains
          else
            c.trains.reject(&:obsolete)
          end.size > @game.phase.train_limit(c)
        end
      end
    end
  end
end
