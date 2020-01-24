# frozen_string_literal: true

module Engine
  class City
    attr_reader :name, :revenue, :slots

    def initialize(revenue, slots = 1, name = nil)
      @revenue = revenue.to_i
      @slots = slots.to_i
      @name = name
    end

    def ==(other)
      (other.class == City) && (@revenue == other.revenue) && (@slots == other.slots) && (@name == other.name)
    end
  end
end
