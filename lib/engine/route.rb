# frozen_string_literal: true

require 'engine/game_error'

module Engine
  class Route
    attr_reader :hexes

    def initialize
      @hexes = []
    end

    def add_hex(hex)
      if (prev = @hexes.last) && !hex.connected?(prev)
        raise GameError, 'Cannot use {hex.name} in route because it is not connected'
      end

      @hexes << hex
    end
  end
end
