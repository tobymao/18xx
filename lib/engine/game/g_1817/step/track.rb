# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G1817
      module Step
        class Track < Engine::Step::Track
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError, 'Cannot upgrade mines' if action.hex.assigned?('mine')
            raise GameError, 'Cannot upgrade ranches' if action.hex.assigned?('ranch')

            super

            psm = @game.pittsburgh_private
            return if action.hex.name != @game.abilities(psm, 'tile_lay')&.hexes&.first || psm.owned_by_player?

            # PSM loses it's special if something else goes on F13
            @game.log << "#{psm.name} closes as it can no longer be used"
            psm.close!
          end
        end
      end
    end
  end
end
