# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G1844
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def choices_ability(entity)
            return { current_entity.id => "Assign EVA to #{current_entity.name}" } if entity == @game.p7

            super
          end

          def process_choose_ability(action)
            entity = action.entity
            if entity == @game.p4
              @game.lay_p4_overpass!
            elsif entity == @game.p7
              @game.assign_p7_train(current_entity)
            else
              raise GameError, "#{entity.name} does not have a choice ability"
            end
          end
        end
      end
    end
  end
end
