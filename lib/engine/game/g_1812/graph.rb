# frozen_string_literal: true

require_relative '../../graph'

module Engine
  module Game
    module G1812
      class Graph < Engine::Graph
        class MineLink
          attr_reader :chain

          def initialize(chain)
            @chain = chain
          end

          def path?
            false
          end

          def nodes
            @chain[:nodes]
          end
        end

        def walk_token(node, links: false, **opts, &block)
          return super unless links

          node.walk(**opts) do |path, visited_paths, visited|
            result = yield(path, visited_paths, visited)
            if result != :abort && (link = mine_link(path.hex, visited_paths.keys))
              yield(path, visited_paths.merge(link => true), visited)
            end
            result
          end
        end

        private

        def mine_link(hex, paths)
          return unless (mine = @game.mine_node_in(hex))
          return unless (start = paths.rindex { |p| !p.nodes.empty? })

          MineLink.new(@game.mine_chain([paths[start].nodes.first, mine], paths[start..]))
        end
      end
    end
  end
end
