# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1841
      module Step
        class Track < Engine::Step::Track
          # extra state for figuring out which railheads were used by a tile lay
          def round_state
            super.merge({ old_tiles: [] })
          end

          def setup
            @game.select_track_graph
            super
            @round.old_tiles = []
            @unused_railheads = {}
          end

          def lay_tile_action(action, entity: nil, spender: nil)
            old_tile = action.hex.tile
            @previous_railheads = unused_railheads(entity || action.entity) unless @game.loading
            super
            @round.old_tiles << old_tile
            @unused_railheads = {}
          end

          def num_possible_lays(entity)
            return 1 unless @game.major?(entity)

            case @game.phase.name
            when '2'
              @game.railheads(entity).size
            when '3', '4'
              [@game.railheads(entity).size, 2].min
            else
              1
            end
          end

          def can_lay_tile?(entity)
            !entity.tokens.empty? && (@round.num_laid_track < num_possible_lays(entity))
          end

          def check_track_restrictions!(entity, old_tile, new_tile)
            return if @game.loading || !entity.operator?

            raise GameError, 'Must connect to a different base' unless find_railhead(entity, @previous_railheads, old_tile,
                                                                                     new_tile)

            super
          end

          def find_railhead(entity, railheads, old_tile, new_tile)
            return nil if !railheads || railheads.empty?

            graph = @game.graph_for_entity(entity)
            old_paths = old_tile.paths # will this work if old_tile has been reusused already?
            new_tile.paths.each do |np|
              next unless graph.connected_paths(entity)[np]
              next if old_paths.find { |path| np <= path }

              railheads.each do |t|
                return t if graph.connected_paths_by_token(entity, t.city).include?(np)
              end
            end

            # if we are here, must be an upgraded city/town
            new_tile.nodes each do |n|
              railheads.each do |t|
                return t if graph.connected_nodes_by_token(entity, t.city).include?(n)
              end
            end

            nil
          end

          # create list of railheads that haven't been used by tile lays this step
          def calc_unused_railheads(entity)
            railheads = @game.railheads(entity)
            @round.num_laid_track.times do |i|
              # Find new paths on laid tile and determine which railhead it connects to
              new_tile = @round.laid_hexes[i].tile
              old_tile = @round.old_tiles[i]
              railheads.delete(find_railhead(entity, railheads, old_tile, new_tile))
            end
            railheads
          end

          def unused_railheads(entity)
            @unused_railheads[entity] ||= calc_unused_railheads(entity)
          end

          def railhead_connected(entity, hex)
            unused_railheads(entity).each do |t|
              return true if @game.graph_for_entity(entity).connected_hexes_by_token(entity, t.city)[hex]
            end
            false
          end

          def tracker_available_hex(entity, hex)
            connected = railhead_connected(entity, hex)
            return nil unless connected

            tile_lay = get_tile_lay(entity)
            return nil unless tile_lay

            color = hex.tile.color
            return nil if color == :white && !tile_lay[:lay]
            return nil if color != :white && !tile_lay[:upgrade]
            return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)
            return nil if ability_blocking_hex(entity, hex)

            connected
          end
        end
      end
    end
  end
end
