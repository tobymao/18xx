# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhl
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include LayTileChecks
        end
      end
    end
  end
end
