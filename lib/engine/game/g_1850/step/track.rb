# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1850
      module Step
        class Track < Engine::Step::Track
          def pass!
            super
            @game.track_action_processed(current_entity)
          end
        end
      end
    end
  end
end
