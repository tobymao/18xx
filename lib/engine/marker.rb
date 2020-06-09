# frozen_string_literal: true

module Engine
  module Marker
    def used?
      @used
    end

    def use!
      @used = true
    end
  end
end
