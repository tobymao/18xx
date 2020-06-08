# frozen_string_literal: true

module Engine
  class Token
    def initialize
      @used = false
    end

    def used?
      @used
    end

    def use!
      @used = true
    end
  end
end
