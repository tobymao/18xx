# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'skip_abbreviated_round'

module Engine
  module Game
    module G18OE
      module Step
        class Track < Engine::Step::Track
          include SkipAbbreviatedRound

          def setup
            super
            @points_used = 0
          end

          def can_lay_tile?(entity)
            points_available = get_tile_lay(entity) - @points_used
            return false unless points_available.positive?

            !entity.tokens.empty?
          end

          def get_tile_lay(entity)
            @game.tile_point_budget(entity)
          end

          def description
            tile_lay = get_tile_lay(current_entity) - @points_used
            "#{tile_lay} track points"
          end

          def lay_tile_action(action)
            tile = action.tile
            old_tile = action.hex.tile
            points_available = get_tile_lay(action.entity) - @points_used
            points_cost = @game.tile_point_cost(action.entity, old_tile: old_tile)
            raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && points_cost > points_available
            raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && points_cost > points_available

            lay_tile(action)
            @game.log << "Used #{points_cost} tile point(s) to lay tile"
            @game.log << "#{points_available - points_cost} point(s) remaining"
            @game.fulfill_patronage!(action.entity, action.hex)
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

            return nil if hex.tile.color == :blue

            points_available = get_tile_lay(entity) - @points_used
            cost = @game.tile_point_cost(entity, old_tile: hex.tile)
            return nil if cost > points_available

            connected
          end
        end
      end
    end
  end
end
