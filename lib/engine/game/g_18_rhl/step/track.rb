# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhl
      module Step
        class Track < Engine::Step::Track
          include LayTileChecks
        end
      end
    end
  end
end
