# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18Neb
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include LegalTileRotationChecker
        end
      end
    end
  end
end
