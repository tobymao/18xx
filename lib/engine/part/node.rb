# frozen_string_literal: true

module Engine
  module Part
    class Node < Base
      attr_accessor :lanes

      def clear!
        @paths = nil
        @exits = nil
      end

      def solo?
        @tile.nodes.one?
      end

      def paths
        @paths ||= @tile.paths.select { |p| p.nodes.any? { |n| n == self } }
      end

      def exits
        @exits ||= paths.flat_map(&:exits)
      end

      def rect?
        false
      end

      def select(paths, corporation: nil)
        on = paths.map { |p| [p, 0] }.to_h

        walk(on: on, corporation: corporation) do |path|
          on[path] = 1 if on[path]
        end

        on.keys.select { |p| on[p] == 1 }
      end

      # Explore the paths and nodes reachable from this node
      #
      # visited: a hashset of visited Nodes
      # visited_paths: a hashset of visited Paths
      # visited_edges: a hashset of crossed HexEdges (2-size Arr of hex and edge to represent hex edge crossings)
      # on: see Path::Walk
      # corporation: If set don't walk on adjacent nodes which are blocked for the passed corporation
      # skip_track: If passed, don't walk on track of that type (ie: :broad track for 1873)
      # connections: a mutable hashset of path connections
      # max_nodes: max depth of nodes we will try to walk
      #
      # This method recursively bubbles up yielded values from nested Node::Walk and Path::Walk calls
      def walk(visited: nil, on: nil, corporation: nil, visited_paths: {}, visited_edges: nil, skip_track: nil,
               connections: nil, max_nodes: nil)
        return if visited&.[](self)

        visited = visited&.dup || {}
        visited_edges = visited_edges&.dup || {}
        visited[self] = true
        return if max_nodes && visited.size >= max_nodes

        paths.each do |node_path|
          next if node_path.track == skip_track

          if connections
            node_path.walk(visited: visited_paths, on: on, visited_edges: visited_edges, skip_track: skip_track,
                           corporation: corporation, connections: connections, visited_nodes: visited,
                           current_node: self, max_nodes: max_nodes) do |path|
              yield path
            end
          else
            node_path.walk(visited: visited_paths, on: on, visited_edges: visited_edges) do |path, vp, ve|
              yield path
              path.nodes.each do |next_node|
                next if next_node == self
                next if corporation && next_node.blocks?(corporation)
                next if path.terminal?

                next_node.walk(
                  visited: visited,
                  on: on,
                  corporation: corporation,
                  # Is merging what we passed into node_path.walk with what it gave us actually neccessary?
                  visited_paths: visited_paths.merge(vp),
                  visited_edges: visited_edges.merge(ve),
                  skip_track: skip_track,
                ) { |p| yield p }
              end
            end
          end
        end
      end
    end
  end
end
