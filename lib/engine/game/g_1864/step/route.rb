# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1864
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            actions = super
            return actions if actions.empty? || !choosing_pullman?(entity)

            actions + ['choose']
          end

          def choosing_pullman?(entity)
            !@pullman_train && entity.trains.any? { |t| @game.pullman?(t) } && !pullman_train_choices(entity).empty?
          end

          def choice_name
            'Attach the Pullman Car to a train'
          end

          def choices
            pullman_train_choices(current_entity).to_h { |train| [train.id, "#{train.name} train"] }
          end

          def pullman_train_choices(entity)
            @game.route_trains(entity).select do |train|
              train.distance.is_a?(Array) && train.distance.any? { |h| h['nodes'] == ['town'] }
            end
          end

          def process_choose(action)
            entity = action.entity
            train = pullman_train_choices(entity).find { |t| t.id == action.choice }
            raise GameError, 'Cannot attach the Pullman Car to that train' if !train || !choosing_pullman?(entity)

            @log << "#{entity.name} attaches the Pullman Car to a #{train.name} train"
            @pullman_train = train
            @pullman_distance = train.distance
            train.distance = @game.pullman_distance(train)
          end

          def process_run_routes(action)
            super
            detach_pullman
          end

          def detach_pullman
            return unless @pullman_train

            @pullman_train.distance = @pullman_distance
            @pullman_train = nil
          end
        end
      end
    end
  end
end
