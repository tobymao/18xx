# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'
require_relative 'nwr_track_bonus'

module Engine
  module Step
    module G1882
      class Track < Track
        include NwrTrackBonus

        def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
          entity ||= action.entity
          super
          gain_nwr_bonus(action.tile, entity)
        end
      end
    end
  end
end
