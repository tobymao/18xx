# frozen_string_literal: true

module Engine
  module Part
    class Node < Base
      def clear!
        @paths = nil
        @exits = nil
      end

      def solo?
        @tile.nodes.one?
      end

      def paths
        @paths ||= @tile.paths.select { |p| p.node == self }
      end

      def exits
        @exits ||= paths.flat_map(&:exits)
      end

      def select(paths, corporation: nil)
        on = paths.map { |p| [p, 0] }.to_h

        walk(on: on, corporation: corporation) do |path|
          on[path] = 1 if on[path]
        end

        on.keys.select { |p| on[p] == 1 }
      end

      def walk(visited: {}, on: nil, corporation: nil, visited_paths: {})
        return if visited[self]

        visited[self] = true

        paths.each do |node_path|
          visited_local = visited_paths.dup

          node_path.walk(visited: visited_local, on: on) do |path|
            yield path
            next unless (next_node = path.node)
            next if corporation && next_node.blocks?(corporation)

            next_node.walk(
              visited: visited.dup,
              on: on,
              corporation: corporation,
              visited_paths: visited_local,
            ) { |p| yield p }
          end
        end
      end
    end
  end
end
