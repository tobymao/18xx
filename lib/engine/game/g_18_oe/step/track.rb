# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18OE
      module Step
        class Track < Engine::Step::Track
          def setup
            super
            @points_used = 0
          end

          def can_lay_tile?(entity)
            points_available = get_tile_lay(entity) - @points_used
            return false unless points_available.positive?

            entity.tokens.any?
          end

          def get_tile_lay(entity)
            # 3 for minors and regionals, 6 for majors, 9 for nationals
            return 3 if entity.total_shares == 2 || entity.total_shares == 4
            return 6 if entity.total_shares == 10
            # return 9 if national
          end

          def description
            tile_lay = get_tile_lay(current_entity) - @points_used
            "#{tile_lay} track points"
          end

          def lay_tile_action(action)
            tile = action.tile
            old_tile = action.hex.tile
            metropolis = @game.metropolis_tile?(tile)
            points_available = get_tile_lay(action.entity) - @points_used
            points_cost = if tile.color != :yellow && metropolis
                            4
                          elsif (tile.color == :yellow && metropolis) || tile.color != :yellow
                            2
                          else
                            1
                          end
            raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && points_cost > points_available
            raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && points_cost > points_available

            lay_tile(action)
            @game.log << "Used #{points_cost} tile point(s) to lay tile"
            @game.log << "#{points_available - points_cost} point(s) remaining"
            if track_upgrade?(old_tile, tile, action.hex)
              @round.upgraded_track = true
              @round.num_upgraded_track += 1
            end
            @round.num_laid_track += 1
            @round.laid_hexes << action.hex
            @points_used += points_cost
          end

          def tracker_available_hex(entity, hex)
            return nil unless @game.hex_within_national_region?(entity, hex)

            connected = hex_neighbors(entity, hex)
            return nil unless connected

            points_available = get_tile_lay(entity) - @points_used
            return nil unless points_available

            metropolis = @game.metropolis_hex?(hex)
            color = hex.tile.color
            return nil if color == :blue
            return nil if color == :white && metropolis && points_available < 2
            return nil if color == :white && points_available < 1
            return nil if color != :white && metropolis && points_available < 4
            return nil if color != :white && points_available < 2

            connected
          end
        end
      end
    end
  end
end
