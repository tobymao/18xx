# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1888
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def potential_tiles(entity, hex)
            return [] unless (tile_ability = abilities(entity))

            tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
            tiles = @game.tiles.uniq(&:name) if tile_ability.tiles.empty?

            special = tile_ability.special if tile_ability.type == :tile_lay
            tiles
              .compact
              .select do |t|
              (special || @game.phase.tiles.include?(t.color)) && @game.upgrades_to?(hex.tile, t, special,
                                                                                     selected_company: entity)
            end
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless entity == @game.yanda

            tile.rotation.zero?
          end

          # needed to deal with non-plain track connections
          #
          def check_connect(_action, ability)
            return if @game.loading
            return if ability.type == :teleport
            return unless ability.connect
            return if ability.hexes.size < 2
            return if !ability.start_count || ability.start_count < 2 || ability.start_count == ability.count

            all_paths = ability.laid_hexes.flat_map do |hex_id|
              @game.hex_by_id(hex_id).tile.paths
            end.uniq

            visited_hexes = [ability.laid_hexes[0]]
            new_hexes = [ability.laid_hexes[0]]
            until new_hexes.empty?
              added_hexes = []
              new_hexes.each do |hex_id|
                new_hex_paths = @game.hex_by_id(hex_id).tile.paths
                new_hex_paths.each do |path|
                  walked_hexes = path.select(all_paths).map { |p| p.hex.id }.sort.uniq
                  added_hexes.concat(walked_hexes - visited_hexes)
                end
              end
              new_hexes = added_hexes.sort.uniq
              visited_hexes.concat(new_hexes).sort!
            end

            raise GameError, 'Paths must be connected' if ability.laid_hexes.size != visited_hexes.size
          end
        end
      end
    end
  end
end
