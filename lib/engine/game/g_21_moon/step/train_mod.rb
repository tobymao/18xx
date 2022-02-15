# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G21Moon
      module Step
        class TrainMod < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            ACTIONS
          end

          def round_state
            super.merge(
              {
                pending_train_mod: [],
              }
            )
          end

          def active?
            pending_entity
          end

          def current_entity
            pending_entity
          end

          def pending_entity
            pending_train_mod[:entity]
          end

          def pending_train_mod
            @round.pending_train_mod&.first || {}
          end

          def description
            'Add or Remove Depot Train'
          end

          def choice_name
            'UN Contract Action'
          end

          def choices
            remove_trains = @game.depot.upcoming.map(&:name).uniq
            add_trains = remove_trains.dup

            # add in current phase train if missing
            add_trains.unshift(@game.phase.name) if add_trains.first != @game.phase.name

            # never 2 or 10 trains
            remove_trains.delete('2')
            remove_trains.delete('10')
            add_trains.delete('2')
            add_trains.delete('10')

            choice_list = []
            add_trains.each { |t| choice_list << ["+#{t}", "Add a #{t} train"] }
            remove_trains.each { |t| choice_list << ["-#{t}", "Remove a #{t} train"] }

            choice_list.to_h
          end

          def process_pass(action)
            @round.pending_train_mod.shift
            super
          end

          def process_choose(action)
            corp = action.entity
            choice = action.choice
            if choice.include?('+')
              @game.add_to_depot(choice[1..-1], corp)
            else
              @game.remove_from_depot(choice[1..-1], corp)
            end
            @round.pending_train_mod.shift
          end
        end
      end
    end
  end
end
