# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1856
      module Step
        class NationalizationDiscardTrains < Engine::Step::Base
          def actions(entity)
            return [] unless can_discard(entity)

            return %w[discard_train] if must_discard(entity)

            %w[discard_train pass]
          end

          def description
            "#{@game.national.name} Formation: Discard Trains"
          end

          def crowded_corps
            return [@game.national] if can_discard(@game.national)

            []
          end

          def active_entities
            crowded_corps.take(1)
          end

          def active?
            !crowded_corps.empty?
          end

          def process_discard_train(action)
            raise GameError('Only national can discard trains now') unless action.entity == @game.national

            train = action.train
            @game.depot.reclaim_train(train)
            done_discarding unless can_discard(@game.national)
            @log << "#{action.entity.name} discards a #{train.name} train to the pool"
          end

          def pass!
            done_discarding
            super
          end

          def done_discarding
            @game.nationalization_train_discard_trigger = false
            @game.national.remove_ability(@game.abilities(@game.national, :train_limit))
            @game.national.add_ability(@game.class::POST_NATIONALIZATION_TRAIN_ABILITY)
          end

          def trains(corporation)
            time_to_discard && corporation == @game.national && national_discardable_trains
          end

          def time_to_discard
            @game.nationalization_train_discard_trigger
          end

          def can_discard(entity)
            entity == @game.national && time_to_discard && !national_discardable_trains.empty?
          end

          def must_discard(entity)
            entity == @game.national && time_to_discard && @game.national.trains.size > 3
          end

          def national_discardable_trains
            non_permanent_trains = @game.national.trains.select(&:rusts_on)
            permanent_trains = @game.national.trains.reject(&:rusts_on)
            non_permanent_trains + (permanent_trains.size > 3 ? permanent_trains : [])
          end
        end
      end
    end
  end
end
