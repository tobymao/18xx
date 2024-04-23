# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track
          # for debugging
          def process_lay_tile(action)
            LOGGER.debug 'Track >> process_lay_tile'
            LOGGER.debug " >> tile: #{action.tile.inspect}"
            multi_yellow_track_hex(action.entity, action.hex)
            super
            move_oo_reservations(action) unless @round.pending_tokens.empty? # Pending token due to Yellow OO tile
          end

          # ------ Code for track laying rules

          def multi_yellow_track_hex(entity, hex)
            return if @game.loading
            return if @round.laid_hexes.empty?
            return if @round.num_laid_track >= 4

            legal_hexes = []
            neighbors = []

            corp = @round.current_operator
            token_hexes = corp.placed_tokens.map(&:hex)
            token_nodes = token_hexes.map { |h| h.tile.nodes[0].paths }
            connected = hex_neighbors(entity, hex)

            hexes = @round.laid_hexes
            graph = @game.graph_for_entity(current_entity)
            track_route = Engine::Route.new(@game, @game.phase, nil, hexes: hexes)
            connected_hexes = @game.graph_for_entity(entity).connected_hexes(entity)

            # walked_path = hex.tile.paths.map { |p| p.walk() }

            LOGGER.debug " Connection Test Called >> entity: #{entity.inspect}, hex: #{hex.inspect}"
            LOGGER.debug " >> token_hexes: #{token_hexes.inspect}"
            LOGGER.debug " >> token_nodes: #{token_nodes.inspect}"
            # LOGGER.debug " >> walked_path: #{walked_path.inspect}"

            LOGGER.debug " >> laid_hexes: #{@round.laid_hexes.inspect}"
            LOGGER.debug " >> connected hexes: #{connected_hexes}"
            LOGGER.debug " >> connected_paths: #{@game.graph_for_entity(entity).connected_paths(entity)}"
            LOGGER.debug " >> reachable_hexes: #{@game.graph_for_entity(entity).reachable_hexes(entity)}"
            LOGGER.debug " >> route_info: #{@game.graph_for_entity(entity).route_info(entity)}"

            connected_hexes.reject! { |h| h.tile.color != 'white' }
            LOGGER.debug " >> white hexes: #{connected_hexes}"

            hexes.each do |h|
              tile = h.tile
              neighbors = tile.exits.map { |e| h.neighbors[e] }
              LOGGER.debug " Hex #{h.inspect} exits #{tile.exits} neighbors #{neighbors.inspect} "
            end

            empty_neighbors = neighbors.select { |h| h.tile.color == 'white' }
            LOGGER.debug " empty_neighbors #{empty_neighbors.inspect} "

            legal_hexes = empty_neighbors
            legal_hexes.include?(hex) && connected
          end

          def available_hex(entity_or_entities, hex)
            # entity_or_entities is an array when combining private company abilities
            entities = Array(entity_or_entities)
            entity, *_combo_entities = entities

            return multi_yellow_track_hex(entity, hex) if @round.num_laid_track.positive? && !@round.upgraded_track

            tracker_available_hex(entity, hex)
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
