module Engine
  class Hex
    attr_reader :coordinates, :layout, :x, :y

    LETTERS = ('A'..'Z').to_a

    # Coordinates are of the form A1..Z99
    # x and y map to the double coordinate system
    # layout is pointy or flat
    def initialize(coordinates, layout: :pointy)
      @coordinates = coordinates
      @layout = layout
      @x = LETTERS.index(@coordinates[0]).to_i
      @y = @coordinates[1..-1].to_i - 1
    end

  end
end
