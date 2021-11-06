# frozen_string_literal: true

require_relative '../../g_1822/step/track'

module Engine
  module Game
    module G1822MX
      module Step
        class Track < Engine::Game::G1822::Step::Track
          def process_lay_tile(action)
            action.tile.label = 'T' if action.hex.tile.label.to_s == 'T'
            super
          end
        end
      end
    end
  end
end
