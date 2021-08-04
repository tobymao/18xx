# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative 'nwr_track_bonus'

module Engine
  module Game
    module G1882
      module Step
        class Track < Engine::Step::Track
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
end
