# frozen_string_literal: true

require 'engine/game_error'

module Engine
  class Route
    attr_reader :hexes, :paths, :train

    def initialize(phase, train)
      @hexes = []
      @paths = []
      @phase = phase
      @train = train
    end

    def reset!
      @hexes.clear
      @paths.clear
    end

    def add_hex(hex)
      if (prev = @hexes.last) && !hex.connected?(prev, true)
        raise GameError, "Cannot use #{hex.name} in route because it is not connected"
      end

      @hexes << hex
      return unless prev

      @paths.concat(hex.connections(prev, true))
    end

    def paths_for(paths)
      @paths & paths
    end

    def stops
      @paths
        .flat_map { |path| [path.city, path.town, path.offboard] }
        .compact
        .uniq
    end

    def revenue
      stops.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end
  end
end
