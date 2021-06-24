# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Carolinas
      module Step
        class Track < Engine::Step::Track
          LAY_ACTIONS = %w[lay_tile pass].freeze
          CONVERT_ACTIONS = %w[run_routes pass].freeze
          ALL_ACTIONS = %w[lay_tile run_routes pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.company? || !can_lay_tile?(entity) && @mode == :new_track
            return ALL_ACTIONS if @game.loading && @game.phase.available?('5')

            @mode == :new_track ? LAY_ACTIONS : CONVERT_ACTIONS
          end

          def setup
            @mode = :new_track
            super
          end

          def update_tile_lists(tile, old_tile)
            @game.update_tile_lists!(tile, old_tile)
          end

          def mode_enabled?
            @game.phase.available?('5')
          end

          def mode_text
            @mode == :new_track ? 'Track Conversion Mode' : 'Tile Lay/Upgrade Mode'
          end

          def change_mode
            return :new_track unless @game.phase.available?('5')

            @mode = @mode == :new_track ? :convert_segment : :new_track
          end

          def prefill_routes?(_entity)
            false
          end

          def instructions
            'Click revenue centers, again to cycle paths. Must be from city/offboard to city/offboard'
          end

          def section_header
            'Select Segment for Conversion'
          end

          def show_table_header?
            false
          end

          def show_clear_train_button?
            false
          end

          def show_clear_all_button?
            false
          end

          def show_auto_button?
            false
          end

          def total_str(_revenue)
            'Convert Segment'
          end

          def revenue_fail
            'Invalid Segment'
          end

          def route_revenue_str(_rev)
            '---'
          end

          def process_run_routes(action)
            hexes_to_flip = action.routes[0].all_hexes.select { |h| h.tile.paths.any? { |p| p.track != :broad } }
            raise GameError, 'No tiles with Southern Track submitted' if hexes_to_flip.empty?

            hexes_to_flip.each { |h| @game.flip_tile!(h) }
            pass!
          end

          def available_hex(entity, hex)
            return super if @mode == :new_track

            @game.graph_for_entity(entity).reachable_hexes(entity)[hex]
          end
        end
      end
    end
  end
end
