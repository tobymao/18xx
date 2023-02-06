# frozen_string_literal: true

require_relative '../../g_1822/step/track'

module Engine
  module Game
    module G1822PNW
      module Step
        class Track < Engine::Game::G1822::Step::Track
          def available_hex(entity, hex)
            return nil if @game.tokencity?(hex) && (!get_tile_lay(entity) & [:upgrade])
            return true if @game.can_hold_builder_cubes?(hex.tile) && @game.graph.connected_hexes(entity)[hex]
            return nil if hex.tile.icons.any? { |i| i.name.start_with?('mountain') }

            super
          end

          def potential_tiles(entity, hex)
            tiles = super
            tiles << @game.cube_tile if @game.can_hold_builder_cubes?(hex.tile)
            tiles << @game.tile_by_id('PNW5-0') if hex.tile.name == 'PNW4'
            tiles = @game.tokencity_potential_tiles(hex, tiles) if @game.tokencity?(hex)
            tiles
          end

          def legal_tile_rotation?(entity, hex, tile)
            return true if hex.tile.name == tile.name && hex.tile.rotation == tile.rotation
            return true if tile == @game.cube_tile
            return true if @game.legal_city_and_town_tile(hex, tile)

            super
          end

          def process_lay_tile(action)
            raise GameError, 'Cannot place a tile or cube now' if @round.num_laid_portage.positive?

            if action.tile == @game.cube_tile
              tile_lay = get_tile_lay(action.entity)
              raise GameError, 'Cannot lay a builder cube now' if !tile_lay || !tile_lay[:lay]

              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              @round.num_laid_track += 1
              @round.laid_hexes << action.hex
            else
              forest = @game.forest?(action.hex.tile)
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
              action.hex.assign!('forest') if forest
            end
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            raise GameError, 'Cannot upgrade forests' if action.hex.assigned?('forest')

            super
          end

          def track_upgrade?(_from, _to, hex)
            @game.tokencity?(hex) || super
          end

          def border_cost_discount(entity, spender, border, cost, hex)
            hex == @game.seattle_hex ? 75 : super
          end
        end
      end
    end
  end
end
