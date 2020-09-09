# frozen_string_literal: true

module Engine
  class Connection
    attr_reader :paths

    def self.connect!(hex)
      connections = {}

      node_paths, paths = hex.tile.paths.partition(&:node?)

      paths.each do |path|
        path.walk { |p| node_paths << p if p.node? }
      end

      node_paths.uniq.each do |node_path|
        connection = Connection.new
        node_path.walk do |path|
          hex = path.hex
          connection = connection.branch!(path)
          next if connection.paths.include?(path)
          next if (connection.nodes & path.nodes).any?
          next if connection.paths.any? { |p| p.hex == hex && (p.exits & path.exits).any? }

          connections[connection] = true
          connection.add_path(path)

          if path.exits.empty?
            hex_connections = hex.connections[:internal]
            hex_connections << connection unless hex_connections.include?(connection)
          else
            path.exits.each do |edge|
              hex_connections = hex.connections[edge]
              hex_connections << connection unless hex_connections.include?(connection)
            end
          end
        end
      end

      connections.keys.uniq { |c| c.paths.sort }.each do |new|
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
      @id = nil
    end

    def matches?(connection_hexes)
      id == connection_hexes || id.reverse == connection_hexes
    end

    def id
      @id ||=
        begin
          sorted = []
          path_map = {}
          node_path = nil

          @paths.each do |path|
            node_path = path if path.node?
            path_map[path] = true
          end

          node_path.walk(on: path_map) do |path|
            sorted << path
          end

          sorted.map { |path| path.hex.id }
        end
    end

    def add_path(path)
      @paths << path
      clear_cache
      raise 'Connection cannot have more than two nodes' if nodes.size > 2
    end

    def clear_cache
      @nodes = nil
      @hexes = nil
      @id = nil
    end

    def nodes
      @nodes ||= @paths.flat_map(&:nodes)
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

    def branch!(path)
      branched_paths = path.select(@paths)
      return self if @paths.size == branched_paths.size

      branch = self.class.new(branched_paths)

      branched_paths.each do |p|
        p.exits.each do |edge|
          p.hex.connections[edge] << branch
        end
      end

      branch
    end

    def inspect
      node_str = nodes.map { |node| node.hex&.name || 'null' }.join(',')
      path_str = @paths.map(&:inspect).join(',')
      "<#{self.class.name}: nodes: #{node_str}, paths: #{path_str}>"
    end
  end
end
