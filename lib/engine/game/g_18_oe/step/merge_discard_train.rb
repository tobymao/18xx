# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class MergeDiscardTrain < Engine::Step::Base
          ACTIONS = %w[discard_train pass].freeze

          def actions(entity)
            return [] unless active_entities.include?(entity)

            ACTIONS
          end

          def active?
            !declinable_trains.empty?
          end

          def active_entities
            declinable_trains.empty? ? [] : [@round.merge_trains[:corporation]]
          end

          def description
            'Discard Trains'
          end

          def pass_description
            'Keep Trains'
          end

          def process_discard_train(action)
            train = action.train
            corporation = action.entity
            raise GameError, "#{train.name} is not owned by #{corporation.name}" unless corporation.trains.include?(train)

            from_minor = @round.merge_trains[:trains].include?(train)
            @game.depot.reclaim_train(train)
            @log << if from_minor
                      "#{corporation.name} declines #{train.name} from the merged minor"
                    else
                      "#{corporation.name} discards #{train.name}"
                    end
            @round.merge_trains = nil if declinable_trains.empty?
          end

          def process_pass(action)
            log_pass(action.entity)
            @round.merge_trains = nil
          end

          def crowded_corps
            active_entities
          end

          def trains(corporation)
            corporation == @round.merge_trains&.dig(:corporation) ? corporation.trains.dup : []
          end

          private

          def declinable_trains
            merge_trains = @round.merge_trains
            return [] unless merge_trains

            merge_trains[:trains].select { |train| train.owner == merge_trains[:corporation] }
          end
        end
      end
    end
  end
end
