# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'
require_relative 'automatic_loan'

module Engine
  module Step
    module G1867
      class Track < Track
        include AutomaticLoan
        def setup
          super
          @hex = nil
        end

        def lay_tile(action, extra_cost: 0, entity: nil)
          @game.game_error('Cannot lay and upgrade the same tile in the same turn') if action.hex == @hex
          super
          @hex = action.hex
        end
      end
    end
  end
end
