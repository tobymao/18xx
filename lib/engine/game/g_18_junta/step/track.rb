# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 4.2: the normal Track step, plus the Upgrade License. A license held for this
        # Operating Round is used by an upgrade, and expires at the end of the Track step if unused.
        class Track < Engine::Step::Track
          def lay_tile_action(action, entity: nil, spender: nil)
            upgrades_before = @round.num_upgraded_track
            super
            return unless @round.num_upgraded_track > upgrades_before

            corporation = action.entity
            return unless @game.upgrade_license?(corporation)

            @game.consume_upgrade_license!(corporation)
            @log << "#{corporation.name} uses its Upgrade License"
          end

          # Every way out of the step (laying the last tile, passing or being skipped) ends here.
          def pass!
            entity = current_entity
            super
            @game.expire_upgrade_license_if_unused!(entity)
          end
        end
      end
    end
  end
end
