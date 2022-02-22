# frozen_string_literal: true

module Engine
  # Information about an entities operating round
  class OperatingInfo
    attr_reader :routes, :halts, :nodes, :dividend, :revenue, :dividend_kind
    attr_accessor :laid_hexes

    def initialize(runs, dividend, revenue, laid_hexes, dividend_kind: nil)
      # Convert the route into connection hexes as upgrades may break the representation
      @routes = runs.to_h { |run| [run.train, run.connection_hexes] }
      @halts = runs.to_h { |run| [run.train, run.halts] }
      @nodes = runs.to_h { |run| [run.train, run.node_signatures] }
      @revenue = revenue
      @dividend = dividend
      @laid_hexes = laid_hexes
      @dividend_kind = dividend_kind || (dividend.is_a?(Engine::Action::Dividend) ? dividend.kind : 'withhold')
    end
  end
end
