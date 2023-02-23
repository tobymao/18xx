# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18Mag
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def process_choose_ability(action)
            @log << "#{current_entity.name} recieves 10 Ft income from #{action.entity.name}"
            @game.bank.spend(10, current_entity)
            @game.abilities(action.entity, :choose_ability).use!
          end
        end
      end
    end
  end
end
