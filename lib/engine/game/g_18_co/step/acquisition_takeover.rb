# frozen_string_literal: true

require_relative 'takeover'

module Engine
  module Game
    module G18CO
      module Step
        class AcquisitionTakeover < G18CO::Step::Takeover
          def round_state
            super.merge(
              {
                pending_takeover: nil,
                pending_acquisition: nil,
              }
            )
          end

          def takeover_in_progress
            return true if current_entity
            return false unless (pa = @round.pending_acquisition)

            execute_takeover!(pa[:source], pa[:corporation])
            @round.pending_acquisition = nil

            current_entity
          end
        end
      end
    end
  end
end
