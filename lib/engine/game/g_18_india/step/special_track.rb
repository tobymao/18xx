# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G18India
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack

          # Bypass some Step::Tracker tests for Town to City upgrade: maintain exits, and check new exits are valid
          # check tile color to active ability
          def legal_tile_rotation?(entity, hex, tile)
            return false unless (ability = abilities(entity))
            return false if tile.color != :yellow && ability.upgrade_count.zero?
            return false if tile.color == :yellow && ability.lay_count.zero?

            old_tile = hex.tile
            if @game.yellow_town_to_city_upgrade?(old_tile, tile)
              all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
              return false unless all_new_exits_valid

              return (old_tile.exits - tile.exits).empty?
            end

            super
          end

          # highlight according to active ability
          def available_hex(entity, hex)
            return unless (ability = abilities(entity))
            return tracker_available_hex(entity, hex) if ability.hexes&.empty? && ability.consume_tile_lay

            color = hex.tile.color
            return nil if color != :white && ability.upgrade_count.zero?
            return nil if color == :white && ability.lay_count.zero?

            hex_neighbors(entity, hex)
          end
        end
      end
    end
  end
end
