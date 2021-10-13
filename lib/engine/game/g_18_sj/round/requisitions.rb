# frozen_string_literal: true

require_relative '../../../round/choices'

module Engine
  module Game
    module G18SJ
      module Round
        class Choices < Engine::Round::Choices
          def select_entities
            # The player of lowest worth is the chooser
            [@game.operator_for_edelsward_requisition]
          end
        end
      end
    end
  end
end
