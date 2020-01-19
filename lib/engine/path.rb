# frozen_string_literal: true

module Engine
  class Path
    attr_reader :a, :b

    # rubocop:disable Naming/MethodParameterName
    def initialize(a, b)
      @a = a
      @b = b
    end
    # rubocop:enable Naming/MethodParameterName

    def ==(other)
      @a == other.a && @b == other.b
    end
  end
end
