# frozen_string_literal: true

require_relative 'tracker'

module Engine
  module Game
    module G18ZOO
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          TILES_UPGRADABLE_WITH_MOLES = %w[7 X7 8 X8 9 X9].freeze

          include Engine::Game::G18ZOO::Step::Tracker

          def process_lay_tile(action)
            super

            @round.laid_hexes.delete(action.hex)
          end

          def available_hex(entity, hex)
            return false if entity == @game.ancient_maps && hex.tile.color != :white
            return false if entity == @game.moles && !available_hex_for_moles(hex)
            return false if entity == @game.rabbits && !available_hex_for_rabbits(hex)

            super
          end

          def potential_tiles(entity, hex)
            return potential_tiles_for_rabbits(entity, hex) if entity == @game.rabbits
            return potential_tiles_for_moles(entity, hex) if entity == @game.moles

            super
          end

          def hex_neighbors(entity, hex)
            return @game.graph_for_entity(entity.owner).connected_hexes(entity.owner)[hex] if entity == @game.ancient_maps

            super
          end

          private

          def available_hex_for_moles(hex)
            TILES_UPGRADABLE_WITH_MOLES.include?(hex.tile.name)
          end

          def available_hex_for_rabbits(hex)
            !%i[white red gray].include?(hex.tile.color) &&
              !(hex.tile.color == :green && (hex.tile.label.to_s == 'O' || %w[M MM].include?(hex.location_name)))
          end

          def potential_tiles_for_moles(entity, hex)
            return [] unless (tile_ability = abilities(entity))

            tiles = tile_ability.tiles.map { |name| @game.tiles.find { |t| t.name == name } }
            tiles = @game.tiles.uniq(&:name) if tile_ability.tiles.empty?

            special = tile_ability.special if tile_ability.type == :tile_lay
            tiles
              .compact
              .select { |tile| @game.upgrades_to?(hex.tile, tile, special, selected_company: entity) }
          end

          def potential_tiles_for_rabbits(entity, hex)
            tiles = @game.tiles
                         .uniq(&:name)
                         .compact
                         .reject { |tile| %w[80 X80 81 X81 82 X82 83 X83].include?(tile.name) }
            if hex.tile.label.to_s == 'O'
              tiles = tiles.select { |tile| (G18ZOO::Game::RABBITS_UPGRADES[hex.tile.name] || []).include?(tile.name) }
            end
            tiles
              .select { |tile| @game.upgrades_to?(hex.tile, tile, true, selected_company: entity) }
          end
        end
      end
    end
  end
end
