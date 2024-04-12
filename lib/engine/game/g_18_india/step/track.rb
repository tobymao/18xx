# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'tracker'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track
          include Tracker

          # modified to add remove gauge change option in phase IV
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless @round.removed_gauge.empty?
            return [] if entity.company? || !can_lay_tile?(entity)

            actions = %w[lay_tile pass]
            actions << 'remove_gauge_change' if may_remove_gauge_change?(entity)
            actions
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

          def note_text_block
            [
              'May remove a Gauge Change Marker as a track action.',
              'Click on a connected marker to remove it.'
            ]
          end

          def show_note?(entity)
            may_remove_gauge_change?(entity)
          end

          # ------ Code for 'remove_gauge_change' Action [Remove Gauge Change Markers in Phase IV] ------

          def may_remove_gauge_change?(entity)
            num_track_actions = @round.num_laid_track + @round.num_upgraded_track
            @game.phase.name == 'IV' && num_track_actions.zero? && any_gauge_changes? && any_reachable_gauge_changes?(entity)
          end

          def any_gauge_changes?
            !@game.gauge_change_markers.empty?
          end

          # A gague change marker is a pair of hexes, which is reachable if both hexes are connected to entity
          def any_reachable_gauge_changes?(entity)
            @game.gauge_change_markers.map { |marker| reachable_gauge_change?(entity, marker[0], marker[1]) }.any?
          end

          def reachable_gauge_change?(entity, hex, neighbor)
            hex_neighbors(entity, hex) && hex_neighbors(entity, neighbor)
          end

          # NOTE: Triggered by on_click event in View::Game::Borders
          def process_remove_gauge_change(action)
            entity = action.entity
            hex = action.hex
            tile = hex.tile
            edge = action.edge
            neighbor = hex.neighbors[edge]
            raise GameError, "#{entity.name} can not reach that marker" unless reachable_gauge_change?(entity, hex, neighbor)

            tile.borders.reject! {|b| b.edge == edge }
            neighbor.tile.borders.reject! { |nb| nb.edge == hex.invert(edge) }
            @log << "#{entity.name} removed the Gauge Change Marker between #{hex.id} and #{neighbor.id}"
            @round.removed_gauge << [hex.id, neighbor.id].sort
            @game.removed_gauge_change_marker(hex, neighbor)
            LOGGER.debug "Remove GC >> #{@round.removed_gauge} / #{@game.gauge_change_markers.to_s}"
            # pass!
          end

          # ------  ------
          def can_lay_tile?(entity)
            return false unless @round.removed_gauge.empty?

            super
          end

          # for debugging
          def process_lay_tile(action)
            tile = action.tile
            hex = action.hex
            rotation = action.rotation
            old_tile = hex.tile
            LOGGER.debug "Track::process_lay_tile:"
            LOGGER.debug "process_lay_tile >> old_tile.borders #{old_tile.borders.to_s}"
            super
          end

          # Bypass some Step::Tracker tests for Town to City upgrade: maintain exits, and check new exits are valid
          def legal_tile_rotation?(entity, hex, tile)
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
        end
      end
    end
  end
end
