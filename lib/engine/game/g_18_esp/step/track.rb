# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G18ESP
      module Step
        class Track < Engine::Step::TrackAndToken
          include Engine::Game::G18ESP::Tracker
        end
      end
    end
  end
end
