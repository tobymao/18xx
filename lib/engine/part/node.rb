# frozen_string_literal: true

module Engine
  module Part
    class Node < Base
      attr_accessor :lanes

      def ident
        self
      end

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

      def walk(visited: nil, on: nil, corporation: nil, visited_paths: {})
        return if visited&.[](self)

        visited = visited&.dup || {}
        visited[self] = true

        paths.each do |node_path|
          node_path.walk(visited: visited_paths, on: on) do |path, vp|
            yield path
            path.nodes.each do |next_node|
              next if next_node == self
              next if corporation && next_node.blocks?(corporation)
              next if path.terminal?

              next_node.walk(
                visited: visited,
                on: on,
                corporation: corporation,
                visited_paths: visited_paths.merge(vp),
              ) { |p| yield p }
            end
          end
        end
      end
    end
  end
end
