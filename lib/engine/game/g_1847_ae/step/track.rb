# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1847AE
      module Step
        class Track < Engine::Step::Track
          def available_hex(entity, hex)
            return nil if (hex.id == 'E9') && !@game.can_build_in_e9?

            return nil if @game.yellow_tracks_restricted && hex.tile.icons.none? { |i| i.name == entity.hex_color }

            super
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            super unless @game.class::DOUBLE_TOWN_TILES.include?(old_tile.name)
          end
        end
      end
    end
  end
end
