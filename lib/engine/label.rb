# frozen_string_literal: true

module Engine
  class Label
    def initialize(label = nil)
      @label = label
    end

    def to_s
      @label.to_s
    end

    def ==(other)
      (other.class == Label) && (@label == other.to_s)
    end
  end
end
