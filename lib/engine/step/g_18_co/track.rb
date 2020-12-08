# frozen_string_literal: true

require_relative '../track'
require_relative 'tracker'

module Engine
  module Step
    module G18CO
      class Track < Track
        include Tracker

        def process_lay_tile(action)
          lay_tile_action(action)
          clear_upgrade_icon(action.hex.tile)
          collect_mines(action.entity, action.hex)

          pass! unless can_lay_tile?(action.entity)
        end
      end
    end
  end
end
