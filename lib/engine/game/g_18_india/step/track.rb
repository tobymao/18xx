# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track
          # for debugging
          def process_lay_tile(action)
            LOGGER.debug "Track >> process_lay_tile >> entity: #{action.entity.inspect}, tile: #{action.tile.inspect}"
            connected_to_track_laying_path?(action.hex) # verify that hex is connected to laying path
            super
            move_oo_reservations(action) unless @round.pending_tokens.empty? # Pending token due to Yellow OO tile
            @round.next_empty_hexes = get_railhead_hexes
          end

          # ------ Code for track laying rules
          def round_state
            { next_empty_hexes: [] }.merge(super)
          end

          def connected_to_track_laying_path?(hex)
            return if @game.loading
            return if @round.laid_hexes.empty?
            return unless hex.tile.color == 'white'

            @round.next_empty_hexes = get_railhead_hexes if @round.next_empty_hexes.empty?
            @round.next_empty_hexes.include?(hex)
          end

          def get_railhead_hexes
            return [] if @game.loading
            return [] if @round.laid_hexes.empty?

            # check if there is only one 'white' neighbor connected to prior tile => return without walking
            neighbors = @round.laid_hexes.last.tile.exits.map { |e| @round.laid_hexes.last.neighbors[e] }
            empty_neighbors = neighbors.select { |h| h.tile.color == 'white' }
            return empty_neighbors if empty_neighbors.size == 1

            corp = @round.current_operator
            railheads = corp.placed_tokens.map(&:city)
            placed_paths = @round.laid_hexes.map(&:tile).map(&:paths) # paths on all previously laid hexes
            LOGGER.debug "railhead_hexes >> corp: #{corp.inspect}, railheads: #{railheads.inspect}"
            return [] unless railheads.any?

            next_hexes = []
            railheads.first.walk(corporation: corp) do |path, v_p, visited|
              # check if path ends at targeted "white" hex
              empty_neighbors = path.exits.map { |e| path.hex.neighbors[e] }.reject { |h| h.tile.color != 'white' }
              next unless empty_neighbors.any?
              LOGGER.debug " walk >> path: #{path.inspect} > empty_neighbors: #{empty_neighbors.inspect} "

              # test if the visted path includes a path from all placed tiles
              visited_path_array = v_p.keys
              include_array = placed_paths.map { |paths_on_tile| (paths_on_tile & visited_path_array).any? }
              next unless include_array.all?

              # test that all tiles are visted in the correct sequence along the visted path
              sequence = placed_paths.map { |t_ps| t_ps.map { |p| visited_path_array.index(p) }.compact.min }
              next unless sequence.each_cons(2).all? { |x,y| x < y }
              LOGGER.debug " >> path found!!! >> sequence: #{sequence.inspect} "
              next_hexes << empty_neighbors
            end
            LOGGER.debug "railhead_hexes >> next_hexes: #{next_hexes.inspect}"
            next_hexes.flatten
          end

          def available_hex(entity_or_entities, hex)
            return super unless @round.num_laid_track.positive?

            connected_to_track_laying_path?(hex)
          end

          # ------


          # Base code doesn't handle one token and a reservation in first city on OO tile
          # Moves a reservation from city to hex to allow any of the two cities to be tokened
          # Reservation to be moved back to empty city after token is placed (See HomeTrack < HomeToken)
          def move_oo_reservations(action)
            tile = action.tile
            LOGGER.debug "Track::move_oo_reservations > tile.labels: #{tile.labels}"
            cities = tile.cities
            reservations = cities.flat_map(&:reservations).compact + tile.reservations
            LOGGER.debug "Track::move_oo_reservations > reservations: #{reservations}"
            tile.reservations = reservations.uniq
            cities.each(&:remove_all_reservations!)
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
