# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'

module Engine
  module Step
    module G1817
      class Track < Track
        def setup
          super
          @hex = nil
        end

        def lay_tile(action, extra_cost: 0, entity: nil)
          @game.game_error('Can lay and upgrade the same time') if action.hex == @hex
          super
          @hex = action.hex
        end
      end
    end
  end
end
