# frozen_string_literal: true

require_relative '../../g_1822/step/tracker'

module Engine
  module Game
    module G1822MX
      module Tracker
        include Engine::Game::G1822::Tracker

        def potential_tiles(entity, hex)
          if @game.port_company?(entity)
            tile_ability = abilities(entity)
            tile = @game.tiles.find { |t| t.name == tile_ability.tiles[0] }
            return [tile]
          elsif @game.cube_company?(entity)
            return @game.can_hold_builder_cubes?(hex.tile) ? [@game.tile_by_id('BC-0')] : []
          end
          tiles = super
          if @game.can_hold_builder_cubes?(hex.tile)
            cube_tile = @game.tile_by_id('BC-0')
            tiles << cube_tile
          end
          tiles
        end

        def legal_tile_rotation?(entity, hex, tile)
          return true if hex.tile.name == tile.name && hex.tile.rotation == tile.rotation
          return true if tile.id == 'BC-0'
          return hex.tile.paths[0].exits == tile.exits if @game.port_company?(entity)
          return true if @game.cube_company?(entity)

          # Per rule, a tile specifically placed in M22 must connect Mexico City to existing track, unless
          # it is the MC that is placing it.
          if hex.id == 'M22' && entity.id != 'MC'
            path_to_mc = tile.paths.find { |p| p.edges[0].num == 5 }
            return false unless path_to_mc

            exit_out = tile.paths.find { |p| p.town == path_to_mc.town && p != path_to_mc }.edges[0].num
            @m22_adjacent_hexes ||= { 0 => 'N21', 1 => 'M20', 2 => 'L21', 3 => 'L23', 4 => 'M24' }
            return @game.hex_by_id(@m22_adjacent_hexes[exit_out]).tile.exits.include?((exit_out + 3) % 6)
          end
          super
        end
      end
    end
  end
end
