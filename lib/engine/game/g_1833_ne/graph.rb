# frozen_string_literal: true

require_relative '../../graph'

module Engine
  module Game
    module G1833NE
      class Graph < Engine::Graph
        def wall?(node)
          @roots[node] || false
        end

        def no_blocking?
          true
        end
      end
    end
  end
end
