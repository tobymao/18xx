# frozen_string_literal: true

require_relative '../../g_1822/step/route'

module Engine
  module Game
    module G1822Africa
      module Step
        class Route < G1822::Step::Route
          def choosing?(entity)
            choosing_pullman?(entity) || choosing_safari?(entity)
          end

          def choices
            if choosing_pullman?(current_entity)
              pullman_choices
            elsif choosing_safari?(current_entity)
              safari_choices
            else
              {}
            end
          end

          def choice_name
            if choosing_pullman?(current_entity)
              'Attach pullman (P+) to a train'
            elsif choosing_safari?(current_entity)
              'Which train will be a safari train (S)'
            end
          end

          def choice_explanation
            if choosing_pullman?(current_entity)
              description = ['Selected train will be able to count any number of towns']
              description << 'You will be able to select Safari Train next' if find_safari_train(current_entity)
              description
            elsif choosing_safari?(current_entity)
              ['Selected train will get +20 bonus for each Game Reserve visited']
            end
          end

          def process_choose(action)
            if choosing_pullman?(current_entity)
              process_pullman_choice(action)
            elsif choosing_safari?(current_entity)
              process_safari_choice(action)
            end
          end

          def pullman_choices
            choices = {}
            pullman_train_choices(current_entity).each_with_index do |train, index|
              choices[index.to_s] = "#{train.name} train"
            end
            choices['None'] = 'None'
            choices
          end

          def process_pullman_choice(action)
            entity = action.entity

            if action.choice == 'None'
              @pullman_train = true
              @log << "#{entity.id} chooses not to attach the pullman to a train"
            else
              @pullman_train = pullman_train_choices(entity)[action.choice.to_i]
              @log << "#{entity.id} attaches the pullman to a #{@pullman_train.name} train"
              attach_pullman
            end
          end

          def detach_pullman
            return super unless @pullman_train == true

            @pullman_train = nil
          end

          def choosing_safari?(entity)
            @safari_train ||= nil
            !@safari_train && find_safari_train(entity) && !safari_train_choices(entity).empty?
          end

          def find_safari_train(entity)
            entity.trains.find { |t| @game.safari_train?(t) }
          end

          def safari_choices
            choices = {}
            safari_train_choices(current_entity).each_with_index do |train, index|
              choices[index.to_s] = "#{train.name} train"
            end
            choices['None'] = 'None'
            choices
          end

          def safari_train_choices(entity)
            pullman_train_choices(entity).reject { |t| t.name.include?('+') }
          end

          def process_safari_choice(action)
            entity = action.entity

            if action.choice == 'None'
              @safari_train = true
              @log << "#{entity.id} chooses to not use a safari train"
            else
              @safari_train = safari_train_choices(entity)[action.choice.to_i]
              @log << "#{entity.id} makes #{@safari_train.name} a safari train"

              attach_safari_train
            end
          end

          def attach_safari_train
            @safari_original_train = @safari_train.dup
            @safari_train.name += 'S'
          end

          def detach_safari_train
            @safari_train.name = @safari_original_train.name

            @safari_original_train = nil
            @safari_train = nil
          end
        end
      end
    end
  end
end
