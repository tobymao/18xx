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
        node_path.walk(chain: []) do |chain|
          next unless valid_connection?(chain)

          connection = Connection.new(chain)
          connections[connection] = true

          chain.each do |path|
            hex = path.hex
            if path.exits.empty?
              hex_connections = hex.connections[:internal]
              hex_connections << connection
            else
              path.exits.each do |edge|
                hex_connections = hex.connections[edge]
                hex_connections << connection
              end
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
          sorted = []
          junction_map = {}

          # skip over paths that have a junction we've already seen
          @paths.each do |path|
            sorted << path unless junction_map[path.a] || junction_map[path.b]
            junction_map[path.a] = true if path.a.junction?
            junction_map[path.b] = true if path.b.junction?
          end

          sorted.map { |path| path.hex.id }
        end
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

    def inspect
      node_str = nodes.map { |node| node.hex&.name || 'null' }.join(',')
      path_str = @paths.map(&:inspect).join(',')
      "<#{self.class.name}: nodes: #{node_str}, paths: #{path_str}>"
    end
  end
end
