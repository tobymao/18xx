# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'
require_relative 'nwr_track_bonus'

module Engine
  module Step
    module G1882
      class Track < Track
        include NwrTrackBonus

        def lay_tile(action)
          super
          gain_nwr_bonus(action.tile, action.entity)
        end
      end
    end
  end
end
