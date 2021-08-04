# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18EU
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::Tracker

          def process_lay_tile(action)
            # TODO: Mountain to Rough change

            super
          end
        end
      end
    end
  end
end
