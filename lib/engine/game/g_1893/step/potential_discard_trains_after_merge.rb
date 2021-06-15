# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1893
      module Step
        class PotentialDiscardTrainsAfterMerge < Engine::Step::DiscardTrain
          ACTIONS = %w[discard_train pass].freeze

          def actions(entity)
            return [] unless @game.potential_discard_trains.include?(entity)

            ACTIONS
          end

          def description
            'Optional Discard of Any Trains'
          end

          def help
            'President may discard any number of trains - click on the ones '\
            'to discard, or pass when not wanting to discard any more. If number'\
            ' of trains exceed train limit, discard must be done to have a legal'\
            ' amount of trains.'
          end

          def entities
            @game.potential_discard_trains.map(:player)
          end

          def log_skip(entity)
            super unless entity.corporation?
          end

          def crowded_corps
            return [] if @game.potential_discard_trains.empty?

            [discarding_entity]
          end

          def active?
            return false if @game.potential_discard_trains.empty?

            true
          end

          def blocking?
            active?
          end

          def process_discard_train(action)
            train = action.train
            @game.depot.reclaim_train(train)
            @log << "#{action.entity.name} discards a #{train.name} train"
            return unless action.entity.trains.empty?

            @game.potential_discard_trains.shift
          end

          def process_pass(action)
            if action.entity.trains.size > @game.train_limit(action.entity)
              raise GameError, "#{action.entity.name} exceeds train limit of #{@ŋame.train_limit(action.entity)}"
            end

            @game.potential_discard_trains.shift
            super
          end

          def trains(corporation)
            corporation.trains
          end

          def context_entities
            [discarding_entity]
          end

          def active_context_entity
            discarding_entity.owner
          end

          private

          def discarding_entity
            @game.potential_discard_trains.first
          end
        end
      end
    end
  end
end
