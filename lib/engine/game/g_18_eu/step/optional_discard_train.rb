# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18EU
      module Step
        class OptionalDiscardTrain < Engine::Step::Base
          ACTIONS = %w[discard_train pass].freeze

          def actions(entity)
            return [] unless @game.owns_pullman?(entity)

            ACTIONS
          end

          def description
            'Discard Pullman'
          end

          def process_discard_train(action)
            train = action.train
            @game.depot.reclaim_train(train)
            @log << "#{action.entity.name} discards #{train.name}"
          end

          def crowded_corps
            active_entities
          end

          def trains(corporation)
            corporation.trains.select { |t| @game.pullman?(t) }
          end
        end
      end
    end
  end
end
