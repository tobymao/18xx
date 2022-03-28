# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative '../../../step/automatic_loan'

module Engine
  module Game
    module G1867
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::AutomaticLoan

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            super
            @game.place_639_token(action.hex.tile) if action.tile.name == '639'
          end

          def connects_to?(hex, tile, to)
            dir = hex.neighbor_direction(to)
            tile.exits.include?(dir)
          end
        end
      end
    end
  end
end
