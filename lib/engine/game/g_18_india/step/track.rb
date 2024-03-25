# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18India
      module Step
        class Track < Engine::Step::Track
          # for debugging
          def process_lay_tile(action)
            LOGGER.debug "Track >> process_lay_tile"
            super
            move_oo_reservations(action) unless @round.pending_tokens.empty? # Pending token due to Yellow OO tile
          end

          # Base code doesn't handle one token and a reservation in first city on OO tile
          # Moves a reservation from city to hex to allow any of the two cities to be tokened
          # Reservation to be moved back to empty city after token is placed (See HomeTrack < HomeToken)
          def move_oo_reservations(action)
            tile = action.tile
            LOGGER.debug  "Track::move_oo_reservations > tile.labels: #{tile.labels.to_s}"
            cities = tile.cities
            reservations = cities.flat_map(&:reservations).compact + tile.reservations
            LOGGER.debug "Track::move_oo_reservations > reservations: #{reservations.to_s}"
            tile.reservations = reservations.uniq
            cities.each { |city| city.remove_all_reservations!}
          end

          # Bypass some Step::Tracker tests for Town to City upgrade: maintain exits, and check new exits are valid
          def legal_tile_rotation?(entity, hex, tile)
            old_tile = hex.tile
            if @game.yellow_town_to_city_upgrade?(old_tile, tile)
              all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
              return false unless all_new_exits_valid

              return old_tile.paths.all? { |old| tile.paths.any? { |new| old.exits == new.exits } } &&
                     !(tile.exits & hex_neighbors(entity, hex)).empty?
            end

            super
          end

          # close P4 if ability was activated
          def pass!
            company = @round.discount_source
            unless company.nil?
              @game.company_is_closing(company)
              company.close!
            end
            super
          end
        end
      end
    end
  end
end
