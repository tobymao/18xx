# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'pay_tile'

module Engine
  module Game
    module G18Mag
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include G18Mag::Step::PayTile
        end
      end
    end
  end
end
