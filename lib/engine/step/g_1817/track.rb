# frozen_string_literal: true

require_relative '../tracker'
require_relative '../track'
require_relative '../upgrade_track_max_exits'

module Engine
  module Step
    module G1817
      class Track < Track
        include UpgradeTrackMaxExits
        # Special track lays act as normal lays for 1817
        attr_accessor :laid_track

        def setup
          super
          @hex = nil
        end

        def lay_tile(action, extra_cost: 0, entity: nil)
          raise GameError, 'Cannot lay and upgrade the same tile in the same turn' if action.hex == @hex
          raise GameError, 'Cannot upgrade mines' if action.hex.assigned?('mine')

          super
          @hex = action.hex

          return unless action.hex.name == @game.class::PITTSBURGH_PRIVATE_HEX

          # PSM loses it's special if something else goes on F13
          psm = @game.company_by_id(@game.class::PITTSBURGH_PRIVATE_NAME)
          return unless (ability = @game.abilities(psm, :tile_lay))

          psm.remove_ability(ability)
          @game.log << "#{psm.name} closes as it can no longer be used"
          psm.close!
        end
      end
    end
  end
end
