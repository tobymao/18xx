# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :hexes, :paths, :phase, :train

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
      if (prev = @hexes.last) && !hex.connected?(prev)
        raise GameError, "Cannot use #{hex.name} in route because it is not connected"
      end

      @hexes << hex
      return unless prev

      @paths.concat(hex.connections(prev, direct: true))
    end

    def paths_for(paths)
      @paths & paths
    end

    def stops
      @paths.map(&:stop).compact.uniq
    end

    def revenue
      stops_ = stops
      raise GameError, 'Too many stops' if @train.distance < stops_.size

      stops_.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end
  end
end
