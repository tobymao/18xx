# frozen_string_literal: true

module Engine
  class Connection
    attr_reader :paths

    def self.walk(connections, visited: {}, corporation: nil)
      connections.each do |connection|
        connection.walk(visited: visited, corporation: corporation) { |c| yield c }
      end
    end

    def self.connect!(hex)
      connection = Connection.new
      connections = {}

      hex.tile.paths.each do |p|
        p.walk do |path|
          hex = path.hex
          connection = connection.branch!(path)
          connection.add_path(path)
          connections[connection] = true

          path.exits.each do |edge|
            hex_connections = hex.connections[edge]
            hex_connections << connection unless hex_connections.include?(connection)
          end
        end
      end

      connections.keys.each do |new|
        new_paths = new.paths

        new_paths.each do |path|
          path.exits.each do |edge|
            path.hex.connections[edge].reject! do |old|
              old_paths = old.paths
              old != new && (!old_paths.all?(&:hex) || (old_paths - new_paths).empty?)
            end
          end
        end
      end
    end

    def initialize(paths = [])
      @paths = paths
      @nodes = nil
      @hexes = nil
    end

    def add_path(path)
      @paths << path unless @paths.include?(path)
      clear_cache
      raise 'Connection cannot have more than two nodes' if nodes.size > 2
      raise 'Connection cannot have two paths on the same hex' if hexes.uniq.size < hexes.size
    end

    def clear_cache
      @nodes = nil
      @hexes = nil
      @path_map = nil
    end

    def path_map
      @path_map ||= @paths.map { |p| [p, true] }.to_h
    end

    def nodes
      @nodes ||= @paths.map(&:node).compact
    end

    def hexes
      @hexes ||= @paths.map(&:hex)
    end

    def complete?
      nodes.size == 2
    end

    def include?(hex)
      hexes.include?(hex)
    end

    def connections(corporation: nil)
      connections = []
      nodes.each do |node|
        connections.concat(connections_for(node)) unless node.blocks?(corporation)
      end
      connections.uniq!
      connections
    end

    def connections_for(node)
      connections = []
      hex = node.hex

      (node.offboard? ? @paths : hex.tile.paths).each do |path|
        next unless path.node == node

        path.exits.each do |edge|
          connections.concat(hex.connections[edge])
        end
      end
      connections.uniq!
      connections
    end

    def walk(visited: {}, corporation: nil)
      return if visited[self]

      visited[self] = true
      yield self

      connections(corporation: corporation).each do |connection|
        connection.walk(visited: visited, corporation: corporation) { |c | yield c }
      end
    end

    def branch!(path)
      branched_paths = []
      path.walk { |p| branched_paths << p if path_map[p] }
      return self if @paths.size == branched_paths.size

      branch = self.class.new(branched_paths)

      branched_paths.each do |path|
        path.exits.each do |edge|
          path.hex.connections[edge] << branch
        end
      end

      branch
    end

    def inspect
      # node_str = nodes.map(&:hex).map(&:name).join(',')
      node_str = nodes.map { |node| node.hex&.name || 'null' }.join(',')
      path_str = @paths.map(&:inspect).join(',')
      "<#{self.class.name}: nodes: #{node_str}, paths: #{path_str}>"
    end
  end
end
