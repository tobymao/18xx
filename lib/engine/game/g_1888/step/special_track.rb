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
        end
      end
    end
  end
end
