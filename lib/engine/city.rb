# frozen_string_literal: true

module Engine
  class City
    attr_reader :revenue

    def initialize(revenue)
      @revenue = revenue.to_i
    end

    def ==(other)
      @revenue == other.revenue
    end
  end
end
