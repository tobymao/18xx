# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G1844
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def process_choose_ability(action)
            entity = action.entity
            raise GameError, "#{entity.name} does not have a choice ability" if entity.id != 'P4'

            @game.lay_p4_overpass!
          end
        end
      end
    end
  end
end
