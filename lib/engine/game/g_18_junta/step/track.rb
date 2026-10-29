# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 4.1 and 4.2: the normal Track step, plus the Upgrade License. A license held for
        # this Operating Round is used by an upgrade, and expires at the end of the Track step if unused.
        # An upgrade without a license makes the president draw a corruption token from the bag.
        class Track < Engine::Step::Track
          def lay_tile_action(action, entity: nil, spender: nil)
            upgrades_before = @round.num_upgraded_track
            super
            return unless @round.num_upgraded_track > upgrades_before

            use_license_or_draw_corruption!(action.entity)
          end

          def use_license_or_draw_corruption!(corporation)
            if @game.upgrade_license?(corporation)
              @game.consume_upgrade_license!(corporation)
              @log << "#{corporation.name} uses its Upgrade License"
            else
              @game.draw_corruption_token!(corporation.owner, 'upgrading without a license')
            end
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
