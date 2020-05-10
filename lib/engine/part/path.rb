# frozen_string_literal: true

require_relative 'base'

module Engine
  module Part
    class Path < Base
      attr_reader :a, :b, :branch, :city, :edges, :junction, :node, :offboard, :stop, :town

      def self.walk(paths, exits = [], visited = {})
        paths.zip(exits).each do |path, exits|
          path.walk(exits, visited) { |p| yield p }
        end
      end

      #def self.walk(paths)
      #  queue = paths.map { |path| [path, path.exits] }
      #  visited = paths.map { |p| [p, true] }.to_h

      #  while (path, exits = queue.pop)
      #    yield path

      #    hex = path.hex
      #    exits.each do |edge|
      #      np_edge = hex.invert(edge)
      #      hex.neighbors[edge].paths[np_edge].each do |np|
      #        next if visited[np]

      #        queue << [np, np.exits - [np_edge]]
      #        visited[np] = true
      #      end
      #    end
      #  end
      #end

      def initialize(a, b)
        @a = a
        @b = b
        @edges = []

        separate_parts
      end

      def <=(other)
        (@a <= other.a && @b <= other.b) ||
          (@a <= other.b && @b <= other.a)
      end

      def walk(edges = nil, visited = {})
        return if visited[self]

        visited[self] = true
        yield self

        (edges || exits).each do |edge|
          np_edge = hex.invert(edge)
          hex.neighbors[edge].paths[np_edge].each do |np|
            np.walk(np.exits - [np_edge], visited) { |p| yield p }
          end
        end
      end

      def path?
        true
      end

      def exits
        @edges.map(&:num)
      end

      def rotate(ticks)
        path = Path.new(@a.rotate(ticks), @b.rotate(ticks))
        path.tile = @tile
        path
      end

      def inspect
        name = self.class.name.split('::').last
        "<#{name}: hex: #{hex&.name}, exit: #{exits}>"
      end

      private

      def separate_parts
        [@a, @b].each do |part|
          case
          when part.edge?
            @edges << part
          when part.offboard?
            @offboard = part
            @stop = part
            @node = part
          when part.city?
            @city = part
            @branch = part
            @stop = part
            @node = part
          when part.junction?
            @junction = part
            @branch = part
            @node = part
          when part.town?
            @town = part
            @branch = part
            @stop = part
            @node = part
          end
        end
      end
    end
  end
end
