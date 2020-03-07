# frozen_string_literal: true

require 'engine/game_error'

module Engine
  class Route
    attr_reader :hexes, :paths

    def initialize
      @hexes = []
      @paths = []
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
      @paths.flat_map(&:cities).size + @paths.flat_map(&:towns).size
    end

    def revenue; end
  end
end
