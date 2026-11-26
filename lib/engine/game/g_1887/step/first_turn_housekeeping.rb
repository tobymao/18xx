# frozen_string_literal: true

require_relative '../../g_1822/step/first_turn_housekeeping'

module Engine
  module Game
    module G1887
      module Step
        class FirstTurnHousekeeping < G1822::Step::FirstTurnHousekeeping
          def actions(entity)
            return [] if @game.industry?(entity)

            super
          end
        end
      end
    end
  end
end
