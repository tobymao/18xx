# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G18India
      module Step
        module RailheadTracker
          # Implements track laying rule for multiple yellow tiles
          # Track laying starts at a railhead(token) and must extend a route(path) from all laid tiles

          def setup
            super
            @round.next_empty_hexes = nil
            @round.laid_yellow_hexes = []
          end

          def round_state
            super.merge({ next_empty_hexes: nil, laid_yellow_hexes: [] })
          end

          def calculate_railhead_hexes
            return [] if @round.laid_yellow_hexes.empty?

            # check simple case of only one 'white' neighbor connected to prior tile => return without walking
            last_yellow_hex = @round.laid_yellow_hexes.last
            neighbors = last_yellow_hex.tile.exits.map { |e| last_yellow_hex.neighbors[e] }
            empty_neighbors = neighbors.select { |h| h.tile.color :white }
            LOGGER.debug "railhead_hexes >> empty_neighbors: #{empty_neighbors.uniq.inspect}" \
                         " exits: #{last_yellow_hex.tile.exits.inspect}"
            return empty_neighbors if empty_neighbors.one? && last_yellow_hex.tile.exits.size <= 2 # exclude triple town tiles

            corp = @round.current_operator
            railheads = corp.placed_tokens.map(&:city)
            placed_paths = @round.laid_yellow_hexes.map(&:tile).map(&:paths) # paths on all previously laid yellow hexes
            LOGGER.debug "railhead_hexes >> corp: #{corp.inspect}, railheads: #{railheads.inspect}"
            return [] unless railheads.any?

            next_hexes = []
            railheads.each do |railhead|
              railhead.walk(corporation: corp) do |path, visited_paths, _visited|
                # check if path ends at targeted "white" hex
                empty_neighbors = path.exits.map { |e| path.hex.neighbors[e] }.select { |h| h.tile.color == 'white' }
                next unless empty_neighbors.any?

                # check if visited path has at least one path from all placed tiles (triple town tiles may have unused paths)
                visited_path_array = visited_paths.keys
                placed_paths_visited = placed_paths.map { |paths_on_tile| (paths_on_tile & visited_path_array).any? }
                next unless placed_paths_visited.all?

                # confirm that placed tiles are visited in the correct sequence along the visited path
                sequence = placed_paths.map { |tile_paths| tile_paths.map { |p| visited_path_array.index(p) }.compact.min }
                next unless sequence.each_cons(2).all? { |x, y| x < y }

                LOGGER.debug " >> path found to hex: #{empty_neighbors.inspect}, sequence: #{sequence.inspect}"
                next_hexes.concat(empty_neighbors)
              end
            end
            LOGGER.debug "railhead_hexes >> next_hexes: #{next_hexes.uniq.inspect}"
            next_hexes.uniq
          end

          def connected_to_track_laying_path?(hex)
            return true if @game.loading
            return true if @round.laid_yellow_hexes.empty?
            return unless hex.tile.color == :white

            @round.next_empty_hexes = calculate_railhead_hexes if @round.next_empty_hexes.nil?
            @round.next_empty_hexes.include?(hex)
          end

          def available_hex(entity_or_entities, hex)
            return super if @round.laid_yellow_hexes.empty?

            connected_to_track_laying_path?(hex)
          end
        end
      end
    end
  end
end
