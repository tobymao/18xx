# frozen_string_literal: true

module Engine
  class Edge
    attr_reader :num

    def initialize(num)
      @num = num.to_i
    end

    def ==(other)
      @num == other.num
    end
  end
end
