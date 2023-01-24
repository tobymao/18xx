# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1868WY
      module Step
        module Tracker
          def lay_tile_action(action, **kwargs)
            super
            @game.spend_tile_lay_points(action)
          end
        end
      end
    end
  end
end
