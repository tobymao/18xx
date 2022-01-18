# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1848
      module Tracker
        include Engine::Step::Tracker

        def lay_tile_action(action)
          # Yellow cities on K tiles need the K label added
          add_k = action.hex.tile.label.to_s == 'K'
          super
          action.hex.tile.label = 'K' if add_k
        end
      end
    end
  end
end
