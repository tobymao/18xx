module Engine
  class Map
    attr_reader :hexes

    def initialize(hexes)
      @hexes = hexes
    end
  end
end
