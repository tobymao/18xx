# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18ESP
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if !entity.operator? || entity.runnable_trains.empty? || !@game.can_run_route?(entity)

            @luxury_train ||= nil
            actions = ACTIONS.dup
            actions << 'choose' if !@luxury_train && @game.luxury_ability(entity) && !luxury_train_choices(entity).empty?
            actions
          end

          def choice_name
            'Choose which train you want to attach a tender'
          end

          def choices
            choices = {}
            luxury_train_choices(current_entity).each_with_index do |train, index|
              choices[index.to_s] = "#{train.name} train"
            end
            choices
          end

          def process_choose(action)
            entity = action.entity
            @luxury_train = luxury_train_choices(entity)[action.choice.to_i]
            @log << "#{entity.id} chooses to attach the tender to the #{@luxury_train.name} train"

            attach_luxury
          end

          def attach_luxury
            @orginal_train = @luxury_train.dup
            city_distance = train_city_distance(@luxury_train)
            town_distance = train_town_distance(@luxury_train) + 1
            @luxury_train.name += '+1'
            @luxury_train.distance = [{ 'nodes' => %w[town halt], 'pay' => town_distance, 'visit' => town_distance },
                                      {
                                        'nodes' => %w[city offboard town halt],
                                        'pay' => city_distance,
                                        'visit' => city_distance,
                                      }]
          end

          def luxury_train_choices(entity)
            @game.route_trains(entity)
          end

          def train_city_distance(train)
            return train.distance if train.distance.is_a?(Numeric)

            distance_city = train.distance.find { |n| n['nodes'].include?('city') }
            distance_city ? distance_city['visit'] : 0
          end

          def train_town_distance(train)
            return 0 if train.distance.is_a?(Numeric)

            distance_city = train.distance.find { |n| !n['nodes'].include?('city') }
            distance_city ? distance_city['visit'] : 0
          end

          def detach_luxury
            @luxury_train.name = @orginal_train.name
            @luxury_train.distance = @orginal_train.distance

            @orginal_train = nil
            @luxury_train = nil
          end

          def process_run_routes(action)
            action.entity.goal_reached!(:offboard) if @game.check_offboard_goal(action.entity, action.routes)
            action.entity.goal_reached!(:harbor) if @game.check_harbor_goal(action.entity, action.routes)
            super
            @game.check_p2_aranjuez(action.routes)
            detach_luxury if @luxury_train
          end
        end
      end
    end
  end
end
