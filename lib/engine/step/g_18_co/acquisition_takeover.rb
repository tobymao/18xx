# frozen_string_literal: true

require_relative 'takeover'

module Engine
  module Step
    module G18CO
      class AcquisitionTakeover < Takeover
        def round_state
          {
            pending_takeover: nil,
            pending_acquisition: nil,
          }
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
