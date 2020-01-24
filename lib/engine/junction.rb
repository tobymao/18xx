# frozen_string_literal: true

module Engine
  class Junction
    def ==(other)
      other.class == Junction
    end
  end
end
