# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G21Moon
      module Step
        class Track < Engine::Step::Track
          def setup
            super

            # start with allowing track to either SP or HB
            @game.select_combined_graph
            @hb_connected = false
            @sp_connected = false
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
            @game.hb_graph.clear
            lay_tile_action(action)

            if @hb_connected && !@sp_connected
              @game.select_sp_graph
            elsif !@hb_connected && @sp_connected
              @game.select_hb_graph
            else
              @game.select_combined_graph # normal case when loading
            end

            return if can_lay_tile?(action.entity)

            pass!
            @game.select_combined_graph
          end

          # this is where we see whether the track extends from HB, SP or both
          #
          def check_track_restrictions!(entity, old_tile, new_tile)
            @hb_connected = new_tile.paths.any? { |np| @game.hb_graph.connected_paths(entity)[np] }
            @sp_connected = new_tile.paths.any? { |np| @game.sp_graph.connected_paths(entity)[np] }

            check_border_crossing(entity, new_tile)

            super
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
        end
      end
    end
  end
end
