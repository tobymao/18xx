# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G18Cuba
      module Step
        class Track < Engine::Step::Track
          def tracker_available_hex(entity, hex)
            corp = entity.corporation? ? entity : @game.current_entity

            # 18Cuba: minors cannot build cities except on their home hex
            return nil if corp.type == :minor &&
                          hex.tile.cities.any? &&
                          hex != corp.tokens.first.hex

            super
          end

          def potential_tiles(entity, hex)
            # TODO: upgrade logic to be checked
            # TODO: "none left" illegal tiles still showed in the UI, but should be hidden
            corp = entity.corporation? ? entity : @game.current_entity
            tiles = super

            track_to_reject = corp.type == :minor ? :broad : :narrow
            home_hex = corp.tokens.first&.hex

            tiles.reject! do |tile|
              if corp.type == :minor
                minor_tile_blocked?(tile, hex, home_hex, track_to_reject)
              else
                major_tile_blocked?(tile)
              end
            end

            tiles
          end

          def tile_has_only_track_type?(tile, track_type)
            # Returns true if the tile contains only paths of the specified track type
            # that is not allowed for the corporation
            tile.paths.all? { |path| path.track == track_type }
          end

          def minor_tile_blocked?(tile, hex, home_hex, track_to_reject)
            # Returns true if a tile is illegal for a minor:
            # home hex forbids pure rejected track (broad for minors),
            # other hexes also forbid city tiles
            return tile_has_only_track_type?(tile, track_to_reject) if hex == home_hex

            tile.cities.any? ||
              tile_has_only_track_type?(tile, track_to_reject)
          end

          def major_tile_blocked?(tile)
            # Returns true if a yellow tile is illegal for a major: only pure broad tracks allowed on yellow
            tile.color == :yellow && !tile_has_only_track_type?(tile, :broad)
          end
        end
      end
    end
  end
end
