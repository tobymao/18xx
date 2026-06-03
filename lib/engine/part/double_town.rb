# frozen_string_literal: true

require_relative 'town'

module Engine
  module Part
    class DoubleTown < Town
      attr_reader :sub_stops

      def initialize(revenue, **opts)
        super
        # Town#rect? reads @size directly; must be 2 so rect? returns false
        @size = 2
        @town_a = Town.new(revenue, **opts.merge(size: nil))
        @town_b = Town.new(revenue, **opts.merge(size: nil))
        @sub_stops = [@town_a, @town_b].freeze
      end

      def size
        2
      end

      def walk(
        visited: {},
        corporation: nil,
        visited_paths: {},
        skip_paths: nil,
        counter: Hash.new(0),
        skip_track: nil,
        converging_path: true,
        walk_calls: Hash.new(0),
        backtracking: false,
        &block
      )
        walk_calls[:all] += 1

        return if visited[self]

        walk_calls[:not_skipped] += 1

        visited[self] = true
        visited[@town_a] = true
        visited[@town_b] = true

        paths.each do |node_path|
          next if node_path.track == skip_track
          next if node_path.ignore?

          node_path.walk(
            visited: visited_paths,
            skip_paths: skip_paths,
            skip_track: skip_track,
            counter: counter,
            converging: converging_path,
            walk_calls: walk_calls,
            backtracking: backtracking,
          ) do |path, vp, ct, converging|
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
                converging_path: converging_path || converging,
                walk_calls: walk_calls,
                backtracking: backtracking,
                &block
              )
            end
          end
        end

        return unless converging_path

        visited.delete(self)
        visited.delete(@town_a)
        visited.delete(@town_b)
      end
    end
  end
end
