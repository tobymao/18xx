# frozen_string_literal: true

require_relative '../../g_1822/step/track'

module Engine
  module Game
    module G1822MX
      module Step
        class Track < Engine::Game::G1822::Step::Track
          def setup
            if current_entity.id == 'NDEM'
              @ndem = @game.corporation_by_id('NDEM')
              @ndem_tiles_laid = []
              @ndem_tile_layers = @game.players.select { |p| @ndem.player_share_holders.include?(p) }
              @ndem_route_runner = @ndem_tile_layers.length.positive? ? @ndem_tile_layers[0] : @game.players[0]
              @game.ndem_acting_player = @ndem_tile_layers[0] if @ndem_tile_layers.length.positive?
            end
            super
          end

          def active?
            !(@ndem && @ndem_tile_layers.length.zero?)
          end

          def skip!
            log_skip(current_entity)
            pass!
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
            action.tile.label = 'T' if action.hex.tile.label.to_s == 'T'
            super
          end
        end
      end
    end
  end
end
