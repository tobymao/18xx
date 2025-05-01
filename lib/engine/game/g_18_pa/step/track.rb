# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'tracker'

module Engine
  module Game
    module G18PA
      module Step
        class Track < Engine::Step::Base
          include Engine::Game::G18PA::Tracker
        end
      end
    end
  end
end
