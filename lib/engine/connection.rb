# frozen_string_literal: true

module Engine
  class Connection
    attr_reader :paths

    def self.layable_hexes(connections)
      hexes = Hash.new { |h, k| h[k] = [] }
      explored_connections = {}
      explored_paths = {}
      queue = []

      connections.each do |connection|
        puts "connection - #{connection.inspect}"
        queue << connection
      end

      while queue.any?
        connection = queue.pop
        explored_connections[connection] = true

        connection.paths.each do |path|
          next if explored_paths[path]

          explored_paths[path] = true
          hex = path.hex
          exits = path.exits
          puts "visit #{hex.inspect} #{exits}"
          hexes[hex] |= exits

          exits.each do |edge|
            neighbor = hex.neighbors[edge]
            edge = hex.invert(edge)
            next if neighbor.connections[edge].any?
            puts "coming to neighbor #{neighbor.inspect} #{edge}"
            hexes[neighbor] |= [edge]
          end
        end

        puts "finding connections for connection #{connection.inspect}"

        connection.connections.each do |c|
          queue << c unless explored_connections[c]
        end
      end

      hexes.default = nil
      puts hexes

      hexes
    end

    def self.connect!(path)
      path.node ? connect_node!(path) : connect_edge!(path)
    end

    def self.connect_node!(path)
      puts "connecting node #{path.hex.name} #{path.exits}"
      hex = path.hex
      edge = path.exits[0]

      connections = hex.connections[edge]

      neighbor = hex.neighbors[edge]
      n_edge = hex.invert(edge)
      n_connections = neighbor.connections[n_edge]

      if n_connections.any?
        n_connections.each do |connection|
          next if connections.include?(connection)

          connections << connection
          connection.add_path(path)
          puts "adding connection from neighbors #{n_edge} #{connection}"
        end
      else
        connections << Connection.new(path)

        neighbor.tile.paths.each do |p|
          connect!(p) if p.exits.include?(n_edge)
        end
        puts "new connection #{edge} - #{n_edge} #{connections.inspect}"
      end
    end

    def self.connect_edge!(path)
      puts "connecting edge #{@coordinates} #{path.exits} - #{path.hex&.name}"
      hex = path.hex
      edge_a, edge_b = path.exits

      connections_a = hex
        .neighbors[edge_a]
        .connections[hex.invert(edge_a)]
        .map { |c| c.extract_path!(path) }

      connections_b = hex
        .neighbors[edge_b]
        .connections[hex.invert(edge_b)]
        .map { |c| c.extract_path!(path) }

      merge(connections_a, connections_b).each do |connection|
        puts "** adding path #{path.hex.name} #{path.exits}"
        connection.add_path(path)

        connection.paths.each do |path|
          puts "** adding connection to hex #{path.hex.name} #{path.exits} #{connection.inspect}"
          path.exits.each do |edge|
            path.hex.connections[edge] << connection
          end
        end
      end
    end

    def self.merge(connections_a, connections_b)
      if connections_a.any? && connections_b.any?
        puts "both exists"
        connections_a.flat_map do |connection_a|
          connections_b.map do |connection_b|
            Connection.new(connection_a.paths | connection_b.paths)
          end
        end
      elsif connections_a.any?
        connections_a
      elsif connections_b.any?
        connections_b
      else
        [Connection.new]
      end
    end

    def initialize(paths = nil)
      @paths = Array(paths)
      @nodes = nil
      @hexes = nil
    end

    def add_path(path)
      raise 'Duplicate path' if @paths.include?(path)

      @paths << path
      clear_cache

      raise "Connection cannot have more than two nodes" if nodes.size > 2
    end

    def remove_path(path)
      clear_cache if @paths.delete(path)
    end

    def clear_cache
      @nodes = nil
      @hexes = nil
    end

    def extract_path!(path)
      return branch(path) if hexes.include?(path.hex)

      @paths.each do |p|
        p.exits.each { |edge| p.hex.connections[edge].delete(self) }
      end

      self
    end

    def branch(path)
      hex_paths = @paths
        .reject { |p| p.hex == path.hex }
        .map { |p| [p.hex, p] }
        .to_h

      explored = {}
      queue = []
      queue << path

      while queue.any?
        p = queue.pop
        explored[p] = true
        neighbors = p.hex.neighbors

        p.exits.each do |edge|
          next unless (n_path = hex_paths[neighbors[edge]])

          queue << n_path unless explored[n_path]
        end
      end

      self.class.new(explored.keys - [path])
    end

    def nodes
      @nodes ||= @paths.map(&:node).compact
    end

    def hexes
      @hexes ||= @paths.map(&:hex)
    end

    def connections
      nodes.flat_map { |node| connections_for(node) }
    end

    def connections_for(node)
      return [] unless node

      if node.offboard?
        return @paths.find { |p| p.node == node }.exits.flat_map do |edge|
          node.hex.connections[edge]
        end
      end

      node.hex.all_connections.select do |connection|
        connection.nodes.include?(node)
      end
    end

    def tokened_by?(corporation)
      nodes.any? { |node| node.city? && node.tokened_by?(corporation) }
    end

    def inspect
      node_str = nodes.map(&:hex).map(&:name).join(',')
      path_str = @paths.map(&:inspect).join(',')
      "<#{self.class.name}: nodes: #{node_str}, paths: #{path_str}>"
    end
  end
end
