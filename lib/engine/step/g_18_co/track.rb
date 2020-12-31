# frozen_string_literal: true

require_relative '../track'
require_relative 'tracker'

module Engine
  module Step
    module G18CO
      class Track < Track
        include Tracker

        def setup
          @previous_laid_hexes = []

          super
        end

        def process_lay_tile(action)
          lay_tile_action(action)
          clear_upgrade_icon(action.hex.tile)
          collect_mines(action.entity, action.hex)
          migrate_reservations(action.hex.tile)
          # place_home_token(action.hex.tile, pending_token[:token]) if pending_token

          pass! unless can_lay_tile?(action.entity)
        end

        def available_hex(entity, hex)
          if pending_token(entity)
            return hex == @game.hex_by_id(entity.coordinates) ? hex.tile.exits : nil
          end

          super
        end

        def lay_tile_action(action)
          if @previous_laid_hexes.include?(action.hex)
            raise GameError, "#{action.hex.id} cannot be upgraded as the tile was just laid"
          end

          super

          @previous_laid_hexes << action.hex
        end
      end
    end
  end
end
