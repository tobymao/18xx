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

          def check_track_restrictions!(entity, old_tile, new_tile)
            old_tile.name.include?('iron') && new_tile.name.include?('iron') ? true : super
          end
        end
      end
    end
  end
end
