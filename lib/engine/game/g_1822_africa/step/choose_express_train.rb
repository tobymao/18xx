# frozen_string_literal: true

module Engine
  module Game
    module G1822Africa
      module ChooseExpressTrain
        def express_choice_name
          'Select the train you want to run as Express'
        end

        def choosing_express?(entity)
          @express_train ||= nil
          !@express_train && !express_train_choices(entity).empty?
        end

        def express_train_choices(entity)
          entity.trains.select { |t| @game.can_be_express?(t) }
        end

        def express_choices
          choices = {}
          express_train_choices(current_entity).each_with_index do |train, index|
            choices[index.to_s] = "#{train.name} train"
          end
          choices['Skip'] = 'Skip'
          choices
        end

        def process_express_choice(action)
          entity = action.entity

          if action.choice == 'Skip'
            @express_train = true
            @log << "#{entity.id} chooses to not use an Express train"
          else
            @express_train = express_train_choices(entity)[action.choice.to_i]
            @log << "#{entity.id} makes #{@express_train.name} train Express"

            convert_express_train
          end
        end

        def convert_express_train
          @express_original_train = @express_train.dup
          @express_train.name = 'E/' + @express_train.name[0]
          @express_train.distance = 99
          @express_train.multiplier = 2
        end

        def process_run_routes(action)
          super

          detach_express_train if @express_train
        end

        def detach_express_train
          unless @express_original_train.nil?
            @express_train.name = @express_original_train.name
            @express_train.distance = @express_original_train.distance
            @express_train.multiplier = @express_original_train.multiplier
          end

          @express_original_train = nil
          @express_train = nil
        end
      end
    end
  end
end
