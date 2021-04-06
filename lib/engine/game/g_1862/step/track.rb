# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1862
      module Step
        class Track < Engine::Step::Track
          def upgraded_track(action)
            # this also takes care of adding small stations, since that is never yellow to yellow
            @round.upgraded_track = true if action.tile.color != :yellow || action.tile.label.to_s == 'N'
          end

          def available_hex(entity, hex)
            color = hex.tile.color
            num_towns = hex.tile.towns.size
            num_cities = hex.tile.cities.size
            # allow adding towns to unconnected plain/town tiles
            connected = hex_neighbors(entity, hex) ||
              (color == :green && num_cities.zero? && num_towns < 2) ||
              (color == :brown && num_cities.zero? && num_towns < 3)
            return nil unless connected

            tile_lay = get_tile_lay(entity)
            return nil unless tile_lay

            return nil if color == :white && !tile_lay[:lay]
            return nil if color != :white && !tile_lay[:upgrade]
            return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)

            connected
          end
        end
      end
    end
  end
end
