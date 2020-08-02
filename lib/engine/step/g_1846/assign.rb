# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G1846
      class Assign < Assign
        def assignable_corporations
          @game.minors + @game.corporations
        end
      end
    end
  end
end
