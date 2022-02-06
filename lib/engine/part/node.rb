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

      # Explore the paths and nodes reachable from this node
      #
      # visited: a hashset of visited Nodes
      # corporation: If set don't walk on adjacent nodes which are blocked for the passed corporation
      # visited_paths: a hashset of visited Paths
      # counter: a hash tracking edges and junctions to avoid reuse
      # skip_track: If passed, don't walk on track of that type (ie: :broad track for 1873)
      # tile_type: if :lawson don't undo visited nodes
      #
      # This method recursively bubbles up yielded values from nested Node::Walk and Path::Walk calls
      def walk(
        visited: {},
        corporation: nil,
        visited_paths: {},
        skip_paths: nil,
        counter: Hash.new(0),
        skip_track: nil,
        tile_type: :normal,
        &block
      )
        return if visited[self]

        visited[self] = true

        paths.each do |node_path|
          next if node_path.track == skip_track
          next if node_path.ignore?

          node_path.walk(
            visited: visited_paths,
            skip_paths: skip_paths,
            counter: counter,
            tile_type: tile_type,
          ) do |path, vp, ct|
            ret = yield path, vp, visited
            next if ret == :abort
            next if path.terminal?

            path.nodes.each do |next_node|
              next if next_node == self
              next if corporation && next_node.blocks?(corporation)

              next_node.walk(
                visited: visited,
                counter: ct,
                corporation: corporation,
                visited_paths: vp,
                skip_track: skip_track,
                skip_paths: skip_paths,
                tile_type: tile_type,
                &block
              )
            end
          end
        end

        visited.delete(self) unless tile_type == :lawson
      end
    end
  end
end
