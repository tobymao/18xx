# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G1868WY
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include G1868WY::Step::Tracker
        end
      end
    end
  end
end
