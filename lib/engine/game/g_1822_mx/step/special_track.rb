# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'

module Engine
  module Game
    module G1822MX
      module Step
        class SpecialTrack < Engine::Game::G1822::Step::SpecialTrack
          def potential_tiles(entity, hex)
            return super unless @game.port_company?(entity)

            tile_ability = abilities(entity)
            tile = @game.tiles.find { |t| t.name == tile_ability.tiles[0] }
            [tile]
          end

          def legal_tile_rotation?(entity, hex, tile)
            return super unless @game.port_company?(entity)

            hex.tile.paths[0].exits == tile.exits
          end

          def available_hex(entity, hex)
            return super unless @game.port_company?(entity)

            hex.tile.color == :blue ? [hex.tile.exits] : nil
          end
        end
      end
    end
  end
end
