# frozen_string_literal: true

module Engine
  class Connection
    attr_reader :paths

    def self.calculate_node_paths(hex)
      node_paths = []
      hex.tile.paths.each do |path|
        path.walk { |p| node_paths << p if p.node? }
      end
      node_paths
    end

    def self.connect!(hex)
      connections = {}
      
      hex_edges = {}

      node_paths = calculate_node_paths(hex)

      hex.connections.clear

      node_paths.uniq.each do |node_path|
        node_path.walk(chain: []) do |chain|
          next unless valid_connection?(chain)

          connection = Connection.new(chain)
          connections[connection] = true

          [chain[0], chain[-1]].each do |path|
            hex = path.hex
            #puts chain if hex.id == "D7"
            if path.exits.empty?
              hex_edges[[hex, :internal]] = true
              hex.connections[:internal] << connection
            else
              path.exits.each do |edge|
                hex_edges[[hex, edge]] = true
                hex.connections[edge] << connection
              end
            end
          end
        end
      end

      hex_edges.keys.each do |hex_, edge|
        connections = hex_.connections[edge]
        connections.select!(&:valid?)
        connections.uniq!(&:hash)
      end
    end

    def self.update_connections(connections, mapping)
      connections.each do |e, conns|
        conns.each do |c|
          c.paths.map! { |p| mapping[p] || p }
          c.clear_cache
        end
      end
    end

    def self.migration_connections(hex, old_tile)
      # Migrate old connections from the old tile to the new without re-walking.

      # Create mapping from old paths to new paths
      #puts "migrate", hex.id

      mapping = {}
      old_tile.paths.each do |op|
        mapping[op] = hex.tile.paths.find { |np| (np.exits & op.exits == np.exits) && np.lanes == op.lanes }
      end

      #wanted_hex = 'D6'
      #if hex.id == wanted_hex
      #  puts hex.connections
      #  puts "old_paths",old_tile.paths
      #  puts "new_paths",hex.tile.paths
      #  puts mapping
      #end
      # Update paths on this tile and those referenced, since they share the connection object we only have
      # to change those in this hex.
      update_connections(hex.connections, mapping)

      node_paths = calculate_node_paths(hex)

      node_paths.map(&:hex).uniq.each do |node_hex|
        #puts node_hex.id, node_hex.connections if hex.id == wanted_hex
        update_connections(node_hex.connections, mapping)
      end

    end

    def self.valid_connection?(chain)
      path_hist = {}
      end_hist = Hash.new(0)

      chain.each do |path|
        # invalid if path appears twice
        return false if path_hist[path]

        path_hist[path] = true
        a = path.a
        b = path.b

        # invalid if edge or node appears more than once, or junction appears more than twice (loops)
        return false if !a.junction? && end_hist[a.id].positive?
        return false if !b.junction? && end_hist[b.id].positive?
        return false if end_hist[a.id] > 1
        return false if end_hist[b.id] > 1

        end_hist[a.id] += 1
        end_hist[b.id] += 1
      end

      true
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
          # deal with ambiguous intra-tile path
          if @paths.one? && @paths[0].tile.ambiguous_connection?
            node0, node1 = @paths[0].nodes.map(&:index).sort
            ["#{@paths[0].hex.id} #{node0}.#{node1}"]
          else
            uniq_paths = []
            junction_map = {}

            # skip over paths that have a junction we've already seen
            @paths.each do |path|
              uniq_paths << path if !junction_map[path.a] && !junction_map[path.b]
              junction_map[path.a] = true if path.a.junction?
              junction_map[path.b] = true if path.b.junction?
            end

            uniq_paths.map! { |path| path.hex.id }
          end
        end
    end

    def hash
      @hash ||= @paths.map(&:id).sort!.hash
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

    def valid?
      nodes.size == 2 && @paths.all?(&:hex)
    end

    def include?(hex)
      hexes.include?(hex)
    end

    def inspect
      node_str = nodes.map { |node| node.hex&.name || 'null' }.join(',')
      path_str = @paths.map(&:inspect).join(',')
      "<#{self.class.name}: nodes: #{node_str}, paths: #{path_str}>"
    end
  end
end
