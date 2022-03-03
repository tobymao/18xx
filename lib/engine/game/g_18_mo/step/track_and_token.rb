# frozen_string_literal: true

require_relative '../../g_1846/step/track_and_token'

module Engine
  module Game
    module G18MO
      module Step
        class TrackAndToken < G1846::Step::TrackAndToken
          def process_place_token(action)
            super
            @game.remove_teleport_destination(action.entity, action.city)
          end
        end
      end
    end
  end
end
