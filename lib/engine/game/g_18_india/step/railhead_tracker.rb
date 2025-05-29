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
            return nil unless @round.pending_tokens.empty? # by placed yellow OO tile
            return [] if @round.laid_yellow_hexes.empty?

            # check simple case of only one or two 'white' neighbor connected to prior tile => return without walking
            last_tile = @round.laid_yellow_hexes.last.tile
            unless [1, 6].include?(last_tile.exits.size) # exclude triple town tiles (6 exits) and OO tiles (1 exit)
              empty_neighbors = empty_neighbors(last_tile.hex, last_tile.exits)
              return empty_neighbors if [1, 2].include?(empty_neighbors.size)
            end

            corp = @round.current_operator
            railheads = corp.placed_tokens.map(&:city)
            placed_paths = @round.laid_yellow_hexes.map(&:tile).map(&:paths) # paths on all previously laid yellow hexes

            next_hexes = []
            railheads.each do |railhead|
              railhead.walk(corporation: corp) do |path, visited_paths, _visited|
                # check if path ends at targeted "white" hex
                empty_neighbors = empty_neighbors(path.hex, path.exits)
                next if empty_neighbors.empty?

                # check if visited path has at least one path from all placed tiles (triple town tiles may have unused paths)
                next unless placed_paths.all? { |paths_on_tile| !(paths_on_tile & visited_paths.keys).empty? }

                # confirm that placed tiles are visited in the correct sequence along the visited path
                sequence = placed_paths.map { |tile_paths| tile_paths.map { |p| visited_paths.keys.index(p) }.compact.min }
                next unless sequence.each_cons(2).all? { |x, y| x < y }

                next_hexes.concat(empty_neighbors)
              end
            end
            next_hexes.uniq
          end

          def empty_neighbors(hex, exits)
            hex.neighbors.values_at(*exits).select { |neighbor| neighbor.tile.color == :white }
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
