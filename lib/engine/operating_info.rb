# frozen_string_literal: true

module Engine
  # Information about an entities operating round
  class OperatingInfo
    attr_reader :routes, :dividend, :revenue
    def initialize(runroutes, dividend, revenue)
      # Convert the route into connection hexes as upgrades may break the representation
      @routes = {}
      runroutes.each { |x| @routes[x.train] = x.connection_hexes }

      @revenue = revenue
      @dividend = dividend
    end
  end
end
