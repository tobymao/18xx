# frozen_string_literal: true

require_relative '../../g_1822/step/track'

module Engine
  module Game
    module G1822PNW
      module Step
        class Track < Engine::Game::G1822::Step::Track
          def potential_tiles(entity, hex)
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

            super
          end

          def process_lay_tile(action)
            if action.tile.id == 'BC-0'
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
        end
      end
    end
  end
end
