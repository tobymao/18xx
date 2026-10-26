# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1833NE
      module Step
        class Route < Engine::Step::Route
          def available_hex(entity, hex)
            @game.extension_graph.reachable_hexes(entity)[hex]
          end
        end
      end
    end
  end
end
