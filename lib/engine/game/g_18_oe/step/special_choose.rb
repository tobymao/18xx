# frozen_string_literal: true

require_relative '../../../step/special_choose'

module Engine
  module Game
    module G18OE
      module Step
        class SpecialChoose < Engine::Step::SpecialChoose
          def process_choose_ability(action)
            @game.acquire_swift_metropolitan_train!(@round.current_operator)
            @game.remove_private!(action.entity)
          end
        end
      end
    end
  end
end
