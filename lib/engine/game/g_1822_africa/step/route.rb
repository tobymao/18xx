# frozen_string_literal: true

require_relative '../../g_1822/step/route'
require_relative 'choose_safari_train'
require_relative 'choose_express_train'

module Engine
  module Game
    module G1822Africa
      module Step
        class Route < G1822::Step::Route
          include G1822Africa::ChooseSafariTrain
          include G1822Africa::ChooseExpressTrain

          def choosing?(entity)
            choosing_express?(entity) || choosing_pullman?(entity) || choosing_safari?(entity)
          end

          def choices
            if choosing_express?(current_entity)
              express_choices
            elsif choosing_pullman?(current_entity)
              pullman_choices
            elsif choosing_safari?(current_entity)
              safari_choices
            else
              {}
            end
          end

          def choice_name
            if choosing_express?(current_entity)
              express_choice_name
            elsif choosing_pullman?(current_entity)
              super
            elsif choosing_safari?(current_entity)
              safari_choice_name
            end
          end

          def choice_explanation
            description = []

            if choosing_express?(current_entity)
              description << 'You will be able to attach Pullman next' if find_pullman_train(current_entity)
              description << 'You will be able to select Safari Train afterwards' if find_safari_train(current_entity)
            elsif choosing_pullman?(current_entity)
              description << 'Selected train will be able to count any number of towns'
              description << 'You will be able to select Safari Train next' if find_safari_train(current_entity)
            elsif choosing_safari?(current_entity)
              description << 'Selected train will get +20 bonus for each Game Reserve visited'
            end

            description
          end

          def process_choose(action)
            if choosing_express?(current_entity)
              process_express_choice(action)
            elsif choosing_pullman?(current_entity)
              process_pullman_choice(action)
            elsif choosing_safari?(current_entity)
              process_safari_choice(action)
            end
          end

          def only_e_train?(entity)
            @game.route_trains(entity).none? { |t| @game.train_type(t) == :normal }
          end

          def pullman_train_choices(entity)
            @game.route_trains(entity).reject do |t|
              @game.class::LOCAL_TRAINS.include?(t.name) || @game.train_type(t) == :etrain
            end
          end

          def pullman_choices
            choices = {}
            pullman_train_choices(current_entity).each_with_index do |train, index|
              choices[index.to_s] = "#{train.name} train"
            end
            choices['Skip'] = 'Skip'
            choices
          end

          def process_pullman_choice(action)
            entity = action.entity

            if action.choice == 'Skip'
              @pullman_train = true
              @log << "#{entity.id} chooses not to attach the pullman to a train"
            else
              @pullman_train = pullman_train_choices(entity)[action.choice.to_i]
              @log << "#{entity.id} attaches the pullman to a #{@pullman_train.name} train"
              attach_pullman
            end
          end

          def detach_pullman
            return super unless @pullman_original_train.nil?

            @pullman_train = nil
          end
        end
      end
    end
  end
end
