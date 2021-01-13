# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18Mag
      class DiscardTrain < Base
        ACTIONS = %w[discard_train pass].freeze

        def actions(entity)
          return [] unless entity.minor?
          return [] if entity.trains.empty?

          ACTIONS
        end

        def description
          'Scrap Trains'
        end

        def crowded_corps
          return [current_entity] if current_entity.minor?

          []
        end

        def process_discard_train(action)
          train = action.train
          entity = action.entity
          entity.trains.delete(train)
          @game.depot.unshift_train(train)
          @log << "#{entity.name} scraps a #{train.name} train"
        end

        def trains(corporation)
          corporation.trains
        end
      end
    end
  end
end
