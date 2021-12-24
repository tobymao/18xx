# frozen_string_literal: true

module Engine
  # Information about an entities operating round
  class OperatingInfo
    attr_reader :routes, :halts, :dividend, :revenue
    attr_accessor :laid_hexes

    def initialize(runs, dividend, revenue, laid_hexes)
      # Convert the route into connection hexes as upgrades may break the representation
      @routes = runs.to_h { |run| [run.train, run.connection_hexes] }
      @halts = runs.to_h { |run| [run.train, run.halts] }
      @revenue = revenue
      @dividend = dividend
      @laid_hexes = laid_hexes
    end
  end
end
