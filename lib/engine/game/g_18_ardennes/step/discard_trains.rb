# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G18Ardennes
      module Step
        class DiscardTrains < Engine::Step::DiscardTrain
          ACTIONS = %w[discard_train pass].freeze
          ACTIONS_WITHOUT_PASS = %w[discard_train].freeze

          def actions(entity)
            return [] unless entity == major
            return [] if @round.optional_trains.empty?

            excess_trains.positive? ? ACTIONS_WITHOUT_PASS : ACTIONS
          end

          def description
            'Discard trains'
          end

          def help
            msg = "#{major.id} may accept or decline minor #{minor.id}’s " \
                  "trains. Click on a train to discard it or pass to keep " \
                  "the trains."
            if excess_trains.positive?
              msg += "#{major.id} is over the train limit " \
                     "(#{@game.train_limit(major)}) and must discard at least" \
                     "#{excess_trains == 1 ? 'one train' : 'two trains'} to " \
                     "return to the train limit."
            end
            msg
          end

          def crowded_corps
            return [] if @round.optional_trains.empty?

            [major]
          end

          def trains(_entity)
            excess_trains.positive? ? @major.trains : @round.optional_trains
          end

          def process_discard_train(action)
            # FIXME: if any of the major's trains (not those received from the
            # minor) have been discarded in this step, then we need to check
            # that we are not under the train limit. (Assuming I have
            # understood the rules correctly).
            train = action.train
            @round.optional_trains.delete(train)
            @game.depot.reclaim_train(train)
            @log << "#{action.entity.name} discards a #{train.name} train"
          end

          def process_pass(action)
            # FIXME: if any of the major's trains (not those received from the
            # minor) have been discarded in this step, then we need to check
            # that we are not under the train limit. (Assuming I have
            # understood the rules correctly).
            if excess_trains.positive?
              raise GameError, "#{major.id} is over the train limit"
            end

            @round.optional_trains.clear
            super
          end

          private

          def major
            @round.major
          end

          def minor
            @round.minor
          end

          def excess_trains
            major.trains.size - @game.train_limit(major)
          end
        end
      end
    end
  end
end
