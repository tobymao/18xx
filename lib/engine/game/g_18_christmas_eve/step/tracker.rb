# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18ChristmasEve
      module Tracker
        include Engine::Step::Tracker

        def lay_tile_action(action)
          old_frame_color = action.hex.tile.frame.color
          super
          action.hex.tile.reframe!(old_frame_color)
        end
      end
    end
  end
end
