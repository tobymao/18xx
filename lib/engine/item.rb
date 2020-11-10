# frozen_string_literal: true

module Engine
  class Item
    attr_accessor :description, :cost

    def initialize(description:, cost:)
      @description = description || ''
      @cost = cost || 0
    end

    def ==(other)
      @description == other.description && @cost == other.cost
    end
  end
end
