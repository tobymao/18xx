# frozen_string_literal: true

require_relative '../../g_1867/step/track'
require_relative 'tracker'

module Engine
  module Game
    module G1812
      module Step
        class Track < G1867::Step::Track
          include G1812::Tracker
        end
      end
    end
  end
end
