# frozen_string_literal: true

require_relative 'base'
require_relative 'tokener'

module Engine
  module Step
    class DiscardTrain < Base
      ACTIONS = %w[discard_train].freeze

      def actions(entity)
        puts entity.name
        return [] unless crowded_corps.include?(entity)

        ACTIONS
      end

      def active_entities
        puts crowded_corps&.map(&:name)
        [crowded_corps&.first].compact
      end

      def active?
        # Crowded corps is done after the entire of buy trains is completed
        @round.check_crowded_corps = crowded_corps.any? if @round.check_crowded_corps

        @round.check_crowded_corps
      end

      def description
        'Discard Train'
      end

      def process_discard_train(action)
        train = action.train
        @game.depot.reclaim_train(train)
        @log << "#{action.entity.name} discards #{train.name}"
        @round.check_crowded_corps = false if crowded_corps.none?
      end

      def crowded_corps
        @game.corporations.select do |c|
          c.trains.reject(&:obsolete).size > @game.phase.train_limit
        end
      end
    end
  end
end
