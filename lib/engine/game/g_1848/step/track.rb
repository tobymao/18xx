# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'
require_relative 'skip_boe'

module Engine
  module Game
    module G1848
      module Step
        class Track < Engine::Step::Track
          include Engine::Game::G1848::Tracker
          include SkipBoe
        end
      end
    end
  end
end
