# frozen_string_literal: true

require_relative '../../g_1822/step/track'

module Engine
  module Game
    module G1822PNW
      module Step
        class Track < Engine::Game::G1822::Step::Track
          def setup
            if current_entity.id == 'NDEM'
              @ndem = @game.corporation_by_id('NDEM')
              @ndem_tiles_laid = []
              @ndem_tile_layers = @game.players.select do |p|
                @ndem.player_share_holders.include?(p) && @ndem.player_share_holders[p].positive?
              end
              if @ndem_tile_layers.length.positive?
                @ndem_route_runner = @ndem_tile_layers[0]
                @game.ndem_acting_player = @ndem_tile_layers[0]
              else
                @ndem_route_runner = @game.players[0]
              end
            end
            super
          end

          def actions(entity)
            return [] if @ndem && @ndem_tile_layers.empty?

            super
          end

          def active?
            return super unless @ndem

            !@ndem_tile_layers.empty? || !acted
          end

          def pass!
            if @ndem
              @ndem_tiles_laid << @round.laid_hexes
              @ndem_tile_layers.shift
              if @ndem_tile_layers.empty?
                @round.laid_hexes = @ndem_tiles_laid
                @game.ndem_acting_player = @ndem_route_runner # Setup for route step
                super
              else
                @round.num_laid_track = 0
                @round.upgraded_track = false
                @round.laid_hexes = []
                @game.ndem_acting_player = @ndem_tile_layers[0]
              end
            else
              super
            end
          end

          def process_lay_tile(action)
            @log << "Tile placement for NDEM by #{@game.ndem_acting_player.name}" if @ndem
            action.tile.label = 'T' if action.hex.tile.label.to_s == 'T'
            if action.tile.id == 'BC-0'
              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              @round.num_laid_track += 1
              @round.laid_hexes << action.hex
            else
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
            end
          end

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

          def available_hex(entity, hex)
            return hex_neighbors(entity, hex) if @game.can_hold_builder_cubes?(hex.tile)

            super
          end
        end
      end
    end
  end
end
