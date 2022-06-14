# frozen_string_literal: true

require_relative '../../g_1846/step/track_and_token'
require_relative 'tracker'

module Engine
  module Game
    module G18LosAngeles
      module Step
        class TrackAndToken < G1846::Step::TrackAndToken
          include Tracker
        end
      end
    end
  end
end
