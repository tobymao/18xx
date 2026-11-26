# frozen_string_literal: true

require_relative '../../g_1822/step/minor_acquisition'

module Engine
  module Game
    module G1887
      module Step
        class MinorAcquisition < G1822::Step::MinorAcquisition
          def potentially_mergeable(entity)
            super.reject { |minor| @game.industry?(minor) }
          end
        end
      end
    end
  end
end
