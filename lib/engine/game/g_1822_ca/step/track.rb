# frozen_string_literal: true

require_relative '../../g_1822/step/track'
require_relative 'tracker'

module Engine
  module Game
    module G1822CA
      module Step
        class Track < G1822::Step::Track
          include G1822CA::Tracker
        end
      end
    end
  end
end
