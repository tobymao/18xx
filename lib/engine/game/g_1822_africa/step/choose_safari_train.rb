# frozen_string_literal: true

module Engine
  module Game
    module G1822Africa
      module ChooseSafariTrain
        def safari_choice_name
          'Which train will be a safari train (S)'
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
          choices['Skip'] = 'Skip'
          choices
        end

        def safari_train_choices(entity)
          pullman_train_choices(entity).reject { |t| t.name.include?('+') }
        end

        def process_safari_choice(action)
          entity = action.entity

          if action.choice == 'Skip'
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

        def process_run_routes(action)
          super

          detach_safari_train if @safari_train
        end

        def detach_safari_train
          @safari_train.name = @safari_original_train.name unless @safari_original_train.nil?

          @safari_original_train = nil
          @safari_train = nil
        end
      end
    end
  end
end
