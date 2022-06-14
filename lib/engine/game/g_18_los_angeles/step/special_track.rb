# frozen_string_literal: true

require_relative '../../g_1846/step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G18LosAngeles
      module Step
        class SpecialTrack < G1846::Step::SpecialTrack
          include Tracker
        end
      end
    end
  end
end
