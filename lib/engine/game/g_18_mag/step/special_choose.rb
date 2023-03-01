# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18Mag
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def choice_name
            'Special Choose'
          end

          def round_state
            super.merge({
                          original_train: nil,
                          ma_plus_train: nil,
                        })
          end

          def choices_ability
            abilities = abilities(current_entity)
            choices = abilities.choices
            choices = current_entity.trains.to_h { |t| [t.name, t.name] } if abilities.owner.id == 'MA'
            choices
          end

          def process_choose_ability(action)
            case action.choice
            when 'claim'
              @log << "#{current_entity.name} recieves 10 Ft income from #{action.entity.name}"
              @game.bank.spend(10, current_entity)
            when 'virtual_token'
              action.entity
              @round.terrain_token = true
              @log << "#{current_entity.name} receives a Terrain Token from #{action.entity.name}"
            else
              # train case
              @round.ma_plus_train = current_entity.trains.find { |t| t.name == action.choice }
              @log << "#{action.entity.name} adds +1 range to #{@round.ma_plus_train.name} train"

              convert_plus_one_train(@round.ma_plus_train)
            end

            @game.abilities(action.entity, :choose_ability).use!
          end

          def convert_plus_one_train(train)
            @round.original_train = train.dup
            distance = @round.ma_plus_train.distance
            @round.ma_plus_train.name += '+1'

            if distance.is_a?(Numeric)
              town_distance_value = 1
            else
              town_distance = distance.find { |n| n['nodes'] == ['town'] }
              town_distance_value = town_distance['pay'] + 1
            end
            @round.ma_plus_train.distance = [
                {
                  nodes: %w[city offboard town],
                  pay: distance,
                  visit: distance,
                },
                {
                  nodes: %w[town],
                  pay: town_distance_value,
                  visit: town_distance_value,
                },
              ]
          end
        end
      end
    end
  end
end
