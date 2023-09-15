# frozen_string_literal: true

require_relative '../../g_1822/step/special_choose'

module Engine
  module Game
    module G1822Africa
      module Step
        class SpecialChoose < G1822::Step::SpecialChoose
          def choice_explanation
            @game.choice_explanation
          end
        end
      end
    end
  end
end
