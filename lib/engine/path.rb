# frozen_string_literal: true

module Engine
  class Path
    attr_reader :a, :b

    def initialize(a, b)
      @a = a
      @b = b
    end

    def ==(other)
      @a == other.a && @b == other.b
    end
  end
end
