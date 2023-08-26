# frozen_string_literal: true

require_relative '../../g_1822/step/minor_acquisition'
require_relative 'tracker'

module Engine
  module Game
    module G1822CA
      module Step
        class MinorAcquisition < G1822::Step::MinorAcquisition
          def round_state
            {
              acquiring_major: nil,
            }
          end

          def after_acquire_bank_minor(entity)
            @round.acquiring_major = entity
          end

          def after_acquire_entity_minor(entity)
            @round.acquiring_major = entity
          end
        end
      end
    end
  end
end
