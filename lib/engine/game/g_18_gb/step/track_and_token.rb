# frozen_string_literal: true

require_relative '../../../step/track_and_token'
require_relative 'tracker'

module Engine
  module Game
    module G18GB
      module Step
        class TrackAndToken < Engine::Step::TrackAndToken
          include Engine::Game::G18GB::Tracker
        end
      end
    end
  end
end
