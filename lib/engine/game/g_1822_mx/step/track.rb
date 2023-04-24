# frozen_string_literal: true

require_relative '../../g_1822/step/track'

module Engine
  module Game
    module G1822MX
      module Step
        class Track < Engine::Game::G1822::Step::Track
          def setup
            if current_entity == @game.ndem
              @ndem_tiles_laid = []
              @ndem_tile_layers = @game.players.select do |p|
                @game.ndem.player_share_holders.include?(p) && @game.ndem.player_share_holders[p].positive?
              end
            end
            super
          end

          def actions(entity)
            return [] if current_entity == @game.ndem && @ndem_tile_layers.empty?

            super
          end

          def active?
            if current_entity == @game.ndem
              super && (!@ndem_tile_layers.empty? || !acted)
            else
              super
            end
          end

          def pass!
            if current_entity == @game.ndem
              @ndem_tiles_laid << @round.laid_hexes
              @ndem_tile_layers.shift
              if @ndem_tile_layers.empty?
                @round.laid_hexes = @ndem_tiles_laid
                super
              else
                @round.num_laid_track = 0
                @round.upgraded_track = false
                @round.laid_hexes = []
              end
            else
              super
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

          def process_lay_tile(action)
            @log << "Tile placement for NDEM by #{@ndem_tile_layers.first.name}" if current_entity == @game.ndem
            if action.tile.id == 'BC-0'
              tile_lay = get_tile_lay(action.entity)
              raise GameError, 'Cannot lay a builder cube now' if !tile_lay || !tile_lay[:lay]

              @log << "#{action.entity.name} places builder cube on #{action.hex.name}"
              action.hex.tile.icons << Part::Icon.new('../icons/1822_mx/red_cube', 'block')
              @round.num_laid_track += 1
              @round.laid_hexes << action.hex
              pass! unless can_lay_tile?(action.entity)
            else
              super
              action.hex.tile.icons.reject! { |i| i.name == 'block' }
            end
          end

          def available_hex(entity, hex)
            return hex_neighbors(entity, hex) if @game.can_hold_builder_cubes?(hex.tile)

            super
          end

          def update_token!(action, entity, tile, old_tile)
            tile.cities.each do |c|
              present_corps = []
              tokens_to_delete = []
              c.tokens.compact.each do |t|
                if present_corps.include?(t.corporation)
                  tokens_to_delete << t
                else
                  present_corps << t.corporation
                end
              end
              tokens_to_delete.compact.each do |t|
                @log << "Extra token for #{t.corporation.name} is removed"
                t.destroy!
              end
            end

            super
          end

          def ndem_acting_player
            @ndem_tile_layers&.first
          end

          def help
            current_entity == @game.ndem ? "#{ndem_acting_player.name} is placing tiles for NdeM" : ''
          end
        end
      end
    end
  end
end
