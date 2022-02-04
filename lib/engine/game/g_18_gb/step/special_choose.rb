# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18GB
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def choices_ability(company)
            abilities(company).choices
          end

          def process_choose_ability(action)
            return unless action.choice == 'close'
            return unless action.entity.company?

            @game.close_company(action.entity)
          end
        end
      end
    end
  end
end
