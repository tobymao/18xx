# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/track'
module Engine
  module Game
    module G1830Plus
      module Step
        class Track < Engine::Step::Track
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            super
            @game.prr_graph.clear
            @game.graph.clear
          end
        end
      end
    end
  end
end
