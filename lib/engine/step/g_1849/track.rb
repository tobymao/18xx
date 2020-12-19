# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'

module Engine
  module Step
    module G1849
      class Track < Track
        def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
          action.tile.upgrades = action.hex.tile.upgrades
          super
        end
      end
    end
  end
end
