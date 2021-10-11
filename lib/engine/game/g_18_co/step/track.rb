# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G18CO
      module Step
        class Track < Engine::Step::Track
          include G18CO::Tracker

          def process_lay_tile(action)
            lay_tile_action(action)
            clear_upgrade_icon(action.hex.tile)
            collect_mines(action.entity, action.hex)
            migrate_reservations(action.hex.tile)

            pass! unless can_lay_tile?(action.entity)
          end

          def available_hex(entity, hex)
            if pending_token(entity)
              return hex == @game.hex_by_id(entity.coordinates) ? hex.tile.exits : nil
            end

            super
          end
        end
      end
    end
  end
end
