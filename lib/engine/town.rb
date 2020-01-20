# frozen_string_literal: true

module Engine
  class Town
    attr_reader :name, :revenue

    def initialize(revenue, name = nil)
      @name = name
      @revenue = revenue.to_i
    end

    def ==(other)
      (@revenue == other.revenue) && (@name == other.name)
    end
  end
end
