# frozen_string_literal: true

module Engine
  class Map
    attr_reader :hexes

    def initialize(hexes)
      @hexes = hexes
    end
  end
end
