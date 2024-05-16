# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G18Ardennes
      module Step
        class DeclineTrains < Engine::Step::DiscardTrain
          ACTIONS = %w[discard_train pass].freeze

          def actions(entity)
            return [] unless entity == major
            return [] if trains(entity).empty?

            ACTIONS
          end

          def description
            'Discard trains from minor'
          end

          def pass_description
            'Done'
          end

          def help
            msg = "#{major.id} may accept or decline minor #{minor.id}’s " \
                  'trains. Click on a train to discard it or click ' \
                  '‘Done’ to keep the trains.'
            if over_limit?
              time = @round.operating? ? ", at the end of #{major.id}’s operating turn," : ''
              msg += " #{major.id} is currently over the train limit. If you " \
                     "pass then you will be given#{time} the option to discard " \
                     "any of its trains (not just those from minor #{minor.id}) " \
                     "to bring #{major.id} back down to the train limit."
            end
            msg
          end

          def crowded_corps
            return [] if trains(major).empty?

            [major]
          end

          def trains(_entity)
            @round.optional_trains
          end

          def process_discard_train(action)
            train = action.train
            trains(major).delete(train)
            @game.depot.reclaim_train(train)
            @log << "#{action.entity.name} discards a #{train.name} train"
          end

          def process_pass(action)
            trains(major).clear
            super
          end

          private

          def major
            @round.major
          end

          def minor
            @round.minor
          end

          def over_limit?
            major.trains.size > @game.train_limit(major)
          end
        end
      end
    end
  end
end
