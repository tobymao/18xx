# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G1848
      module Step
        class Track < Engine::Step::Track
          include Engine::Game::G1848::Tracker

          def actions(entity)
            return super unless entity == @game.boe

            []
          end
        end
      end
    end
  end
end
