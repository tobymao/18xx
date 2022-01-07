# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G18ChristmasEve
      module Step
        class Track < Engine::Step::Track
          include Engine::Game::G18ChristmasEve::Tracker
        end
      end
    end
  end
end
