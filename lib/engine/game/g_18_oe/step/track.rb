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
            points_available = remaining_tile_points(entity)
            return false if !points_available.positive? && !@game.zero_point_tile_lays_available?(entity)

            !entity.tokens.empty?
          end

          def auto_actions(entity)
            return unless actions(entity).include?('lay_tile')
            return if remaining_tile_points(entity).positive?

            hexes = @game.graph_for_entity(entity).connected_hexes(entity).keys
            return if hexes.any? { |hex| available_hex(entity, hex) }

            [Engine::Action::Pass.new(entity)]
          end

          def get_tile_lay(entity)
            @game.tile_point_budget(entity)
          end

          def description
            'Lay Track'
          end

          def help
            entity = current_entity
            tile_lay = remaining_tile_points(entity)
            text = "#{tile_lay} track points"
            abilities = @game.terrain_point_abilities(entity)
            return text if abilities.empty?

            points = abilities.keys.map { |color| "1 #{color}-terrain point" }.join(' + ')
            "#{text} + #{points} (yellow lays only)"
          end

          def lay_tile_action(action)
            tile = action.tile
            old_tile = action.hex.tile
            points_available = remaining_tile_points(action.entity)
            points_cost = @game.tile_point_cost(action.entity, old_tile: old_tile)
            raise GameError, 'Cannot lay an upgrade now' if tile.color != :yellow && points_cost > points_available
            raise GameError, 'Cannot lay a yellow now' if tile.color == :yellow && points_cost > points_available

            tile.rotate!(action.rotation)
            action.extra_cost = cross_water_fee(action) unless @game.loading
            lay_tile(action, extra_cost: action.extra_cost || 0)
            @game.after_lay_tile(action.entity, old_tile, tile)
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

            points_available = remaining_tile_points(entity)
            cost = @game.tile_point_cost(entity, old_tile: hex.tile)
            return nil if cost > points_available

            connected
          end

          private

          def remaining_tile_points(entity)
            get_tile_lay(entity) - @points_used
          end

          def cross_water_fee(action)
            fee = @game.cross_water_tile_fee(action.entity, action.hex, action.tile)
            return fee if !action.extra_cost || action.extra_cost == fee

            raise GameError, "Cross-water fee is #{@game.format_currency(fee)}, not #{@game.format_currency(action.extra_cost)}"
          end
        end
      end
    end
  end
end
