# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G21Moon
      module Step
        class Track < Engine::Step::Track
          ACTIONS = %w[lay_tile pass use_graph].freeze

          def actions(entity)
            return [] if entity.corporation? && entity.receivership?
            return [] unless entity == current_entity
            return [] if entity.company? || !can_lay_tile?(entity)

            ACTIONS
          end

          def setup
            super

            # start with allowing track to either SP or LB
            @game.select_combined_graph
            @round.lb_connected = false
            @round.sp_connected = false
            @round.graph_id = nil
          end

          def round_state
            {
              lb_connected: false,
              sp_connected: false,
              graph_id: nil,
            }
          end

          def track_upgrade?(from, _to, _hex)
            !from.preprinted
          end

          # update revenue icons
          def update_tile_lists(tile, old_tile)
            old_tile.icons.dup.each do |old_icon|
              old_tile.icons.delete(old_icon)
              new_icon = @game.update_icon(old_icon, tile)
              tile.icons << new_icon if new_icon
            end
            super
          end

          def process_lay_tile(action)
            @game.graph.clear
            @game.sp_graph.clear
            @game.lb_graph.clear
            lay_tile_action(action)

            return if can_lay_tile?(action.entity)

            pass!
            @game.select_combined_graph
          end

          # this is where we see whether the track extends from LB, SP or both
          #
          def check_track_restrictions!(entity, old_tile, new_tile)
            unless @game.loading
              lb = uses_graph?(entity, @game.lb_graph, old_tile, new_tile)
              sp = uses_graph?(entity, @game.sp_graph, old_tile, new_tile)

              if lb && sp
                @round.graph_id = 'BOTH'
              elsif lb
                @round.graph_id = 'LB'
                if @round.lb_connected && !@round.sp_connected
                  raise GameError, 'Tile must upgrade city or add new track and be connected to SP'
                end
              elsif sp
                @round.graph_id = 'SP'
                if @round.sp_connected && !@round.lb_connected
                  raise GameError, 'Tile must upgrade city or add new track and be connected to LB'
                end
              else
                raise GameError, 'Tile must upgrade city or add new track and be connected to SP or LB'
              end
            end

            check_border_crossing(entity, new_tile)

            super
          end

          def uses_graph?(entity, graph, old_tile, new_tile)
            old_paths = old_tile.paths

            new_tile.paths.each do |np|
              next unless graph.connected_paths(entity)[np]
              return true unless new_tile.cities.empty? # city_permissive

              op = old_paths.find { |path| np <= path }
              next if op

              return true
            end

            false
          end

          def check_border_crossing(entity, tile)
            hex = tile.hex
            tile.borders.dup.each do |border|
              edge = border.edge
              neighbor = hex.neighbors[edge]
              next if !hex.targeting?(neighbor) || !neighbor.targeting?(hex)

              @game.crossing_border(entity, tile) # check and potentially pay bonus

              # remove border
              tile.borders.delete(border)
              neighbor.tile.borders.map! { |nb| nb.edge == hex.invert(edge) ? nil : nb }.compact!
            end
          end

          def tracker_available_hex(entity, hex)
            connected = hex_neighbors(entity, hex)
            return nil unless connected
            return nil if hex.id == @game.class::T_HEX

            tile_lay = get_tile_lay(entity)
            return nil unless tile_lay

            preprinted = hex.tile.preprinted
            return nil if preprinted && !tile_lay[:lay]
            return nil if !preprinted && !tile_lay[:upgrade]

            connected
          end

          def auto_actions(entity)
            return [] unless @round.num_laid_track == 1 # only after first lay
            return [] unless @round.graph_id            # only once and after normal lay

            id = @round.graph_id
            @round.graph_id = false
            [
              Engine::Action::UseGraph.new(
                entity,
                graph_id: id,
              ),
            ]
          end

          def process_use_graph(action)
            @round.lb_connected = action.graph_id == 'LB' || action.graph_id == 'BOTH'
            @round.sp_connected = action.graph_id == 'SP' || action.graph_id == 'BOTH'

            # set the graph based on which base connected to the tile
            if @round.lb_connected && !@round.sp_connected
              @game.select_sp_graph
            elsif !@round.lb_connected && @round.sp_connected
              @game.select_lb_graph
            else
              @game.select_combined_graph # both
            end
          end
        end
      end
    end
  end
end
