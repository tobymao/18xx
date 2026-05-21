# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'lay_tile_check'

module Engine
  module Game
    module G18ESP
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include LayTileCheck

          def process_lay_tile(action)
            owner = action.entity.owner
            super
            owner.goal_reached!(:destination) if @game.check_for_destination_connection(owner)
          end
        end
      end
    end
  end
end
