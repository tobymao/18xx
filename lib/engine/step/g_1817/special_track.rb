# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G1817
      class SpecialTrack < SpecialTrack
        def process_lay_tile(action)
          step = @round.active_step
          raise 'Can only be laid as part of lay track' unless step.is_a?(Step::Track)

          super
          step.laid_track = step.laid_track + 1
        end
      end
    end
  end
end
