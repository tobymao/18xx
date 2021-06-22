# frozen_string_literal: true

require_relative '../../../step/route'
module Engine
  module Game
    module G18KA
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || @game.route_trains(entity).empty? || !@game.can_run_route?(entity)

            @pullman_train_assignments ||= {}
            actions = ACTIONS.dup
            actions << 'choose' if !pullman_choices(entity).empty? && !train_choices(entity).empty?
            actions
          end

          def attach_pullman(train, pullman)
            @pullman_train_assignments[pullman] = train
            city_distance = train_city_distance(train)
            town_distance = train_town_distance(train)
            pullman_size = pullman_distance(pullman)
            train.name = "#{city_distance}+#{town_distance + pullman_size}"
            train.distance = [
              {
                'nodes' => ['town'],
                'pay' => town_distance + pullman_size,
                'visit' => town_distance + pullman_size,
              },
              {
                'nodes' => %w[city offboard town],
                'pay' => city_distance,
                'visit' => city_distance,
              },
            ]
          end

          def choice_name
            'Attach a pullman to a train?'
          end

          def choices
            choices = {}
            pullman_choices(current_entity).each_with_index do |pullman, p_index|
              train_choices(current_entity).each_with_index do |train, t_index|
                choices["#{t_index}-#{p_index}"] = "Attach #{pullman.name} pullman to #{train.name} train"
              end
            end
            choices
          end

          def detach_pullmans
            @pullman_train_assignments.each do |pullman, train|
              city_distance = train_city_distance(train)
              town_distance = train_town_distance(train)
              pullman_size = pullman_distance(pullman)
              if town_distance == pullman_size
                train.name = city_distance.to_s
                train.distance = city_distance
              else
                train.name = "#{city_distance}+#{town_distance - pullman_size}"
                train.distance = [
                  {
                    'nodes' => ['town'],
                    'pay' => town_distance - pullman_size,
                    'visit' => town_distance - pullman_size,
                  },
                  {
                    'nodes' => %w[city offboard town],
                    'pay' => city_distance,
                    'visit' => city_distance,
                  },
                ]
              end
            end
            @pullman_train_assignments = {}
          end

          def train_choices(entity)
            # Diesels don't get pullmans. That'd be silly.
            @game.route_trains(entity).reject { |t| @game.pullman_train?(t) || t.variant['name'] == 'D' }
          end

          def pullman_choices(entity)
            entity.trains.select { |t| @game.pullman_train?(t) && !@pullman_train_assignments[t] }
          end

          def process_choose(action)
            entity = action.entity
            choices = action.choice.split('-', -1).map(&:to_i)
            train = train_choices(entity)[choices[0]]
            pullman = pullman_choices(entity)[choices[1]]
            @log << "#{entity.id} chooses to attach the #{pullman.name} pullman to the #{train.name} train"
            attach_pullman(train, pullman)
          end

          def process_run_routes(action)
            super

            detach_pullmans unless @pullman_train_assignments.empty?
          end

          def train_city_distance(train)
            return train.distance if train.distance.is_a?(Numeric)

            distance_city = train.distance.find { |n| n['nodes'].size > 1 }
            distance_city ? distance_city['visit'] : 0
          end

          def train_town_distance(train)
            return 0 if train.distance.is_a?(Numeric)

            distance_city = train.distance.find { |n| n['nodes'].size == 1 }
            distance_city ? distance_city['visit'] : 0
          end

          def pullman_distance(pullman)
            pullman.name.split('+', -1).last.to_i
          end
        end
      end
    end
  end
end
