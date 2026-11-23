# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'skip_abbreviated_round'
require_relative 'tile_point_tracker'

module Engine
  module Game
    module G18OE
      module Step
        class Track < Engine::Step::Track
          include SkipAbbreviatedRound
          include TilePointTracker

          def round_state
            super.merge(tile_points_used: 0)
          end

          def setup
            super
            @round.tile_points_used = 0
          end

          def actions(entity)
            actions = super
            return actions if actions.empty? || entity != current_entity || entity.company?
            return actions if brandt_removal_choices(entity).empty?

            (actions + %w[choose]).uniq
          end

          def choice_name
            'Brandt & Brandau tokens'
          end

          def choices
            brandt_removal_choices(current_entity)
          end

          def process_choose(action)
            entity = action.entity
            hex = @game.hex_by_id(action.choice)
            if !hex || !brandt_removal_choices(entity).key?(hex.id)
              raise GameError, "No Brandt & Brandau token to remove on #{action.choice}"
            end

            points = @game.brandt_removal_points(hex)
            ability = @game.terrain_point_abilities(entity)[:green]
            if ability
              ability.use!
              points -= 1
            end
            @round.tile_points_used += points
            @game.remove_brandt_token!(entity, hex)
          end

          def brandt_removal_choices(entity)
            return {} if @game.brandt_hexes.empty?

            @game.brandt_hexes.each_with_object({}) do |hex, choices|
              next unless @game.brandt_blocked?(entity, hex)
              next unless @game.hex_within_national_region?(entity, hex)
              next if !@game.loading && !hex_neighbors(entity, hex)

              cost = @game.brandt_removal_cost(entity, hex)
              points = @game.brandt_removal_points(hex)
              covered = @game.terrain_point_abilities(entity).key?(:green) ? 1 : 0
              next if points - covered > remaining_tile_points(entity)
              next if cost > buying_power(entity)

              choices[hex.id] = "Remove B&B token on #{hex.id} (#{@game.format_currency(cost)}, #{points} pt)"
            end
          end

          def can_lay_tile?(entity)
            return true if @game.track_token_placeable?(entity)

            points_available = remaining_tile_points(entity)
            return false if !points_available.positive? && !@game.zero_point_tile_lays_available?(entity)

            !entity.tokens.empty? || @game.national?(entity)
          end

          def auto_actions(entity)
            return unless actions(entity).include?('lay_tile')
            return if remaining_tile_points(entity).positive?
            return if @game.track_token_placeable?(entity)
            return unless brandt_removal_choices(entity).empty?

            hexes = @game.graph_for_entity(entity).connected_hexes(entity).keys
            return if hexes.any? { |hex| available_hex(entity, hex) }

            [Engine::Action::Pass.new(entity)]
          end

          def pay_tile_cost!(entity_or_entities, tile, rotation, hex, spender, cost, extra_cost)
            @game.check_reserved_train_funds!(spender, cost)
            super
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
            right_of_way = !@game.phase.tiles.include?(tile.color)
            raise GameError, 'Right-of-Way is not available' if right_of_way && !right_of_way?(action.entity, action.hex)

            points_cost = right_of_way ? points_available : @game.tile_point_cost(action.entity, old_tile: old_tile)
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
            @round.tile_points_used += points_cost
          end
        end
      end
    end
  end
end
