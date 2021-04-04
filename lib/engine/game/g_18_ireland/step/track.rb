# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Ireland
      module Step
        class Track < Engine::Step::Track
          def hex_neighbors(entity, hex)
            super || @game.narrow_connected_hexes(entity)[hex]
          end

          def process_lay_tile(action)
            super
            @game.clear_narrow_graph
          end
        end
      end
    end
  end
end
