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

          was_connected = @game.sydney_adelaide_connected
          now_connected = @game.check_sydney_adelaide_connected

          @log << 'Sydney and Adelaide are connected - COM may start operating' if !was_connected && now_connected
        end
      end
    end
  end
end
