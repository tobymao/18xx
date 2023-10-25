# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1822
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)
            return [] if entity.corporation? && entity.type == :minor && only_e_train?(entity)

            actions = ACTIONS.dup
            actions << 'choose' if choosing?(entity)
            actions
          end

          def choosing?(entity)
            choosing_pullman?(entity)
          end

          def choosing_pullman?(entity)
            @pullman_train ||= nil
            !@pullman_train && find_pullman_train(entity) && !pullman_train_choices(entity).empty?
          end

          def attach_pullman
            @pullman_original_train = @pullman_train.dup
            distance = train_city_distance(@pullman_train)
            @pullman_train.name += '+'
            @pullman_train.distance = [
              {
                'nodes' => %w[city offboard],
                'pay' => 99,
                'visit' => distance,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ]
          end

          def choice_name
            'Attach pullman (P+) to a train'
          end

          def choices
            choices = {}
            pullman_train_choices(current_entity).each_with_index do |train, index|
              choices[index.to_s] = "#{train.name} train"
            end
            choices
          end

          def detach_pullman
            @pullman_train.name = @pullman_original_train.name
            @pullman_train.distance = @pullman_original_train.distance

            @pullman_original_train = nil
            @pullman_train = nil
          end

          def only_e_train?(entity)
            @game.route_trains(entity).none? { |t| t.name != @game.class::E_TRAIN }
          end

          def pullman_train_choices(entity)
            @game.route_trains(entity).reject do |t|
              @game.class::LOCAL_TRAINS.include?(t.name) || t.name == @game.class::E_TRAIN
            end
          end

          def find_pullman_train(entity)
            entity.trains.find { |t| @game.pullman_train?(t) }
          end

          def process_choose(action)
            entity = action.entity
            @pullman_train = pullman_train_choices(entity)[action.choice.to_i]
            @log << "#{entity.id} attaches the pullman to a #{@pullman_train.name} train"

            attach_pullman
          end

          def process_run_routes(action)
            super

            detach_pullman if @pullman_train
          end

          def train_city_distance(train)
            return train.distance if train.distance.is_a?(Numeric)

            distance_city = train.distance.find { |n| n['nodes'].include?('city') }
            distance_city ? distance_city['visit'] : 0
          end
        end
      end
    end
  end
end
