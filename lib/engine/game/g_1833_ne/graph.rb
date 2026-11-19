# frozen_string_literal: true

require_relative '../../graph'

module Engine
  module Game
    module G1833NE
      class Graph < Engine::Graph
        def extra_root_nodes(corporation)
          super.merge(@game.offboard_token_nodes(corporation).to_h { |node| [node, true] })
        end
      end
    end
  end
end
