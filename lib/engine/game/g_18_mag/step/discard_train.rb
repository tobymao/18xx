# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18Mag
      module Step
        class DiscardTrain < Engine::Step::Base
          ACTIONS = %w[discard_train pass].freeze

          def actions(entity)
            return [] unless entity.minor?
            return [] if entity.trains.empty?

            ACTIONS
          end

          def description
            'Scrap Trains'
          end

          def log_skip(entity)
            super unless entity.corporation?
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
end
