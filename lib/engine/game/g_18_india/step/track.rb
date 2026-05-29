# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'gauge_change_border'
require_relative 'railhead_tracker'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track
          include GaugeChangeBorder
          include RailheadTracker

          # modified to add remove gauge change option in phase IV
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless @round.removed_gauge.empty?
            return [] if entity.company?

            if can_lay_tile?(entity)
              actions = %w[lay_tile pass]
              actions << 'remove_border' if may_remove_gauge_change?
              return actions
            end

            # Tile laid but P2/P3 could still create a token connection: stay
            # blocking so the player can use them before the token window closes.
            return %w[pass] if needs_special_track_for_token?(entity)

            []
          end

          def setup
            super
            @round.removed_gauge = []
          end

          def round_state
            super.merge({ removed_gauge: [] })
          end

          def description
            tile_lay = get_tile_lay(current_entity)
            return 'Lay Track' unless tile_lay

            if tile_lay[:lay] && tile_lay[:upgrade]
              @game.phase.name == 'IV' ? 'Lay/Upgrade Track OR Remove Gauge Change Marker' : 'Lay/Upgrade Track'
            elsif tile_lay[:lay]
              'Lay Track'
            else
              'Upgrade Track'
            end
          end

          # ------ Show a note that gauge changes may be removed ------

          def help
            return [] unless may_remove_gauge_change?

            [
              'May remove a Gauge Change Marker as a track action.',
              'Click on a connected marker to remove it.',
            ]
          end

          # ------ Code for 'remove_gauge_change' Action [Remove Gauge Change Markers in Phase IV] ------

          def may_remove_gauge_change?
            num_track_actions = @round.num_laid_track + @round.num_upgraded_track
            @game.phase.name == 'IV' && num_track_actions.zero? && any_gauge_changes?
          end

          def any_gauge_changes?
            !@game.gauge_change_markers.empty?
          end

          # A gauge change marker is a pair of hexes, which is reachable if both hexes are connected to entity
          def any_reachable_gauge_changes?(entity)
            @game.gauge_change_markers.any? { |marker| reachable_gauge_change?(entity, marker[0], marker[1]) }
          end

          def reachable_gauge_change?(entity, hex, neighbor)
            hex_neighbors(entity, hex) && hex_neighbors(entity, neighbor)
          end

          # NOTE: Triggered by on_click event in View::Game::Part::Borders
          def process_remove_border(action)
            entity = action.entity
            hex = action.hex
            tile = hex.tile
            edge = action.edge
            neighbor = hex.neighbors[edge]
            if !@game.loading && !reachable_gauge_change?(entity, hex, neighbor)
              raise GameError, "#{entity.name} can not reach that marker"
            end

            tile.borders.reject! { |b| b.edge == edge }
            neighbor.tile.borders.reject! { |nb| nb.edge == hex.invert(edge) }
            @log << "#{entity.name} removed the Gauge Change Marker between #{hex.id} and #{neighbor.id}"
            @round.removed_gauge << [hex.id, neighbor.id].sort
            @game.removed_gauge_change_marker(hex, neighbor)
          end

          # ------  ------
          def can_lay_tile?(entity)
            return false unless @round.removed_gauge.empty?

            super
          end

          # Added multiple yellow tile check and Yellow OO reservation check.
          # Does not delegate to super so we can control the pass! condition:
          # if the entity still has company tile-lay abilities (P2/P3) AND the
          # token step would otherwise be skipped, we stay blocking so the
          # player can use P2/P3 to create station access (fixes #11362).
          def process_lay_tile(action)
            if action.tile.color == :yellow
              raise GameError, 'New yellow tiles must extend path from railhead and previously laid tiles' \
               unless connected_to_track_laying_path?(action.hex)

              @round.laid_yellow_hexes << action.hex
            end
            lay_tile_action(action)
            move_oo_reservations(action) unless @round.pending_tokens.empty? # Pending token due to Yellow OO tile
            @round.next_empty_hexes = calculate_railhead_hexes unless @game.loading
            pass! if !can_lay_tile?(action.entity) && !needs_special_track_for_token?(action.entity)
          end

          # Base code doesn't handle one token and a reservation in first city on OO tile
          # Moves a reservation from city to hex to allow any of the two cities to be tokened
          # Reservation to be moved back to empty city after token is placed (See HomeTrack < HomeToken)
          def move_oo_reservations(action)
            tile = action.tile
            cities = tile.cities
            reservations = cities.flat_map(&:reservations).compact + tile.reservations
            tile.reservations = reservations.uniq
            cities.each(&:remove_all_reservations!)
          end

          # Bypass some Step::Tracker tests for Town to City upgrade: maintain exits, and check new exits are valid
          def legal_tile_rotation?(entity, hex, tile)
            return false if tile.name == 'IF2' && tile.rotation == 1

            old_tile = hex.tile
            if @game.yellow_town_to_city_upgrade?(old_tile, tile)
              all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
              return false unless all_new_exits_valid

              return (old_tile.exits - tile.exits).empty?
            end

            super
          end

          # close P4 if ability was activated
          def pass!
            company = @round.discount_source
            unless company.nil?
              @game.company_closing_after_using_ability(company)
              company.close!
            end
            super
          end

          private

          # True only when all three conditions hold:
          #   (a) the entity or its owning player has an active tile-lay ability
          #       (P2 Portuguese EIC or P3 Dutch EIC) — checked for both
          #       corporation-owned and player-owned privates;
          #   (b) the entity's connected network has usable target hexes:
          #       P2 (lay_count > 0) needs a white hex; P3 (upgrade_count > 0)
          #       needs a yellow/green/brown hex to upgrade;
          #   (c) the Token step would currently be skipped (no accessible
          #       station) — if a token can already be placed, Track can
          #       auto-pass normally so the existing "Skip (Token)" pass is not
          #       stolen by Track.
          def needs_special_track_for_token?(entity)
            abilities = special_tile_lay_abilities(entity)
            return false if abilities.empty?

            connected = @game.graph.connected_hexes(entity).keys
            yellow_ok = abilities.any? { |a| a.lay_count&.positive? } &&
                        connected.any? { |h| h.tile.color == :white }
            upgrade_ok = abilities.any? { |a| a.upgrade_count&.positive? } &&
                         connected.any? { |h| %i[yellow green brown].include?(h.tile.color) }
            return false if !yellow_ok && !upgrade_ok

            token_step = @round.steps.find { |s| s.is_a?(Engine::Step::Token) && s.active? }
            return false unless token_step

            !token_step.can_place_token?(entity)
          end

          # Returns all active tile-lay abilities for the entity or its owning player.
          # P2/P3 may be corporation-owned or still player-owned.
          def special_tile_lay_abilities(entity)
            player = entity.owner
            companies = entity.companies
            companies += player.companies if player.respond_to?(:companies)
            companies.filter_map { |c| @game.abilities(c, :tile_lay) }
          end
        end
      end
    end
  end
end
