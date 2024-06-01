# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18Norway
      module Step
        class Route < Engine::Step::Route
          def available_hex(entity, hex)
            return true if super(entity, hex)
            return true if @game.ferry_graph.reachable_hexes(entity)[hex]

            false
          end
        end
      end
    end
  end
end
