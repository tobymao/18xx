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
        node_path.cwalk do |cpaths|
          next unless valid_connection?(cpaths)

          connection = Connection.new(cpaths)
          connections[connection] = true

          cpaths.each do |cp|
            hex = cp.hex
            if cp.exits.empty?
              hex_connections = hex.connections[:internal]
              hex_connections << connection
            else
              cp.exits.each do |edge|
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

    def self.valid_connection?(cpaths)
      path_hist = Hash.new(0)
      end_hist = Hash.new(0)
      cpaths.each do |cp|
        # invalid if path appears twice
        return false if path_hist[cp].positive?

        path_hist[cp] += 1

        # invalid if edge or node appears more than once, or junction appears more than twice (loops)
        return false if !cp.a.junction? && end_hist[cp.a.ident].positive?
        return false if !cp.b.junction? && end_hist[cp.b.ident].positive?
        return false if end_hist[cp.a.ident] > 1
        return false if end_hist[cp.b.ident] > 1

        end_hist[cp.a.ident] += 1
        end_hist[cp.b.ident] += 1
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
