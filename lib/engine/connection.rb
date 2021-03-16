# frozen_string_literal: true

module Engine
  class Connection
    attr_reader :paths

    def self.connect!(hex)
      hex.tile.paths.each do |path|
        path.walk do |_, visited|
          chain = visited.keys
          next unless chain.sum { |p| p.nodes.size } > 1

          path = chain[0]

          connection = Connection.new(chain)

          if path.exits.empty?
            hex.connections[:internal] << connection
          else
            path.exits.each do |edge|
              hex.connections[edge] << connection
            end
          end
        end
      end

      hex.connections.each do |_, connections|
        connections.uniq!(&:hash)
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
