# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G18Cuba
      module Step
        class Track < Engine::Step::Track
          def tracker_available_hex(entity, hex)
            # TODO: FC logic with fee payments
            corp = entity.corporation? ? entity : @game.current_entity

            # 18Cuba: minors cannot build cities except on their home hex
            return nil if corp.type == :minor &&
                          !hex.tile.cities.empty? &&
                          hex != corp.tokens.first.hex

            # Majors may only lay on sugar cane hexes after the sugar_cane_open_for_majors event
            return nil if corp.type == :major &&
                          @game.sugar_cane_hex?(hex) &&
                          !@game.sugar_cane_open_for_majors?

            super
          end

          def potential_tiles(entity, hex)
            corp = entity.corporation? ? entity : @game.current_entity

            super.reject do |tile|
              @game.tile_blocked_for_corp?(tile, corp, hex)
            end
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            # City tiles: "It is not necessary that any of the new track is usable by the company."
            return unless old_tile.cities.empty?

            # Sugar cane (town) tiles: "A minor company may upgrade any sugar cane field tile."
            # Majors are already blocked from pure narrow upgrades via major_tile_blocked?.
            return unless old_tile.towns.empty?

            # Plain track: "may upgrade only if the [narrow/standard] gauge track is extended."
            graph = @game.graph_for_entity(entity)
            old_paths = old_tile.paths
            used_new_track = old_paths.empty?

            new_tile.paths.each do |np|
              next unless graph.connected_paths(entity)[np]

              used_new_track = true unless old_paths.any? { |path| np <= path }
            end

            raise GameError, 'Must use new track' unless used_new_track
          end
        end
      end
    end
  end
end
