# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'

module Engine
  module Game
    module G1817
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::UpgradeTrackMaxExits
          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError, 'Cannot upgrade mines' if action.hex.assigned?('mine')

            super

            psm = @game.company_by_id(@game.class::PITTSBURGH_PRIVATE_NAME)
            return if action.hex.name != @game.class::PITTSBURGH_PRIVATE_HEX || psm.owned_by_player?

            # PSM loses it's special if something else goes on F13
            @game.log << "#{psm.name} closes as it can no longer be used"
            psm.close!
          end
        end
      end
    end
  end
end
