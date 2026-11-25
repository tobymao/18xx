# frozen_string_literal: true

module Engine
  module Game
    module GFrost1831
      module Step
        module NewLondonRoute
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            super
            @game.after_lay_tile(action.hex, action.tile, action.entity)
          end
        end
      end
    end
  end
end
