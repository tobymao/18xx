# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'

module Engine
  module Game
    module G1822PNW
      module Step
        class SpecialTrack < Engine::Game::G1822::Step::SpecialTrack
          def potential_tiles(entity, hex)
            if @game.port_company?(entity)
              tile_ability = abilities(entity)
              tile = @game.tiles.find { |t| t.name == tile_ability.tiles[0] }
              return [tile]
            elsif @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) ? [@game.tile_by_id('BC-0')] : []
            end
            super
          end

          def legal_tile_rotation?(entity, hex, tile)
            return hex.tile.paths[0].exits == tile.exits if @game.port_company?(entity)
            return true if @game.cube_company?(entity)

            super
          end

          def available_hex(entity, hex)
            return hex.tile.color == :blue ? [hex.tile.exits] : nil if @game.port_company?(entity)
            if @game.cube_company?(entity)
              return @game.can_hold_builder_cubes?(hex.tile) && @game.graph.connected_hexes(entity.owner)[hex]
            end

            super
          end

          def process_lay_tile(action)
            if @game.cube_company?(action.entity)
              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              ability = abilities(action.entity)
              ability.use!
              if ability.count.zero? && ability.closed_when_used_up
                company = ability.owner
                @log << "#{company.name} closes"
                company.close!
              end
            else
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
            end
          end
        end
      end
    end
  end
end
