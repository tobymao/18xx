# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'
require_relative '../../../step/upgrade_track_max_exits'

module Engine
  module Game
    module G18USA
      module Step
        class Track < Engine::Step::Track
          include Engine::Step::UpgradeTrackMaxExits

          def lay_tile_action(action, entity: nil, spender: nil)
            tile = action.tile

            super
            @game.company_by_id('P16').close! if tile.name.include?('RHQ')
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            old_tile.name.include?('iron') && new_tile.name.include?('iron') ? true : super
          end
        end
      end
    end
  end
end
