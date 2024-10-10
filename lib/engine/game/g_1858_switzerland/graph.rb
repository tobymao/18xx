# frozen_string_literal: true

require_relative '../g_1858/graph'

module Engine
  module Game
    module G1858Switzerland
      class Graph < G1858::Graph
        private

        def path_node(path, entity)
          node = G1858::Part::PathNode.new(path)
          return node unless path.hex == @game.gotthard

          # The pre-printed Gotthard hex is a special case. It is a home hex
          # for two private railways (FOB and GB) and it has two paths, one
          # broad gauge and one metre (narrow) gauge. FOB is only allowed to
          # trace routes from this hex using the metre gauge path, and GB can
          # only use the broad gauge path.
          return node if (path.track == :broad && entity == @game.gb_minor) ||
                         (path.track == :narrow && entity == @game.fob_minor)
        end
      end
    end
  end
end
