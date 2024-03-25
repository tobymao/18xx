# frozen_string_literal: true

require_relative '../../../step/home_token'
require_relative '../../../step/tracker'

module Engine
  module Game
    module G18India
      module Step
        class HomeTrack < Engine::Step::HomeToken
          include Engine::Step::Tracker
          ACTIONS = %w[lay_tile place_token].freeze

          def actions(entity)
            return [] unless entity == pending_entity

            actions = []
            actions << 'place_token' if any_open_cities?
            actions << 'lay_tile' if any_town_hex?

            actions
          end

          def any_open_cities?
            !@game.open_city_hexes.empty?
          end

          def any_town_hex?
            !@game.town_to_green_city_hexes.empty?
          end

          def description
            "Lay home token in open city or upgrade town for #{pending_entity.name}"
          end

          def process_lay_tile(action)
            LOGGER.debug  "HomeTrack > process_lay_tile"
            lay_tile(action)

            place_token(
              action.entity,
              action.tile.cities[0],
              token,
              connected: false,
              extra_action: true
            )
            @round.pending_tokens.shift
          end

          def process_place_token(action)
            LOGGER.debug  "HomeTrack > process_place_token"
            super
            tile = action.city.tile
            replace_oo_reservations(tile) unless tile.reservations.empty? # move hex reservation
          end

          # Base code doesn't handle one token and one reservation on a OO tile
          # Moves a reservation from hex to untoken city
          def replace_oo_reservations(tile)
            return if tile.reservations.empty?

            cities = tile.cities
            reservations = tile.reservations.dup
            LOGGER.debug "replace_oo_reservations > reservations: #{reservations.to_s}"
            tile.reservations.each do |reservation|
              cities.each do |city|
                if !city.tokened? || cities.count == 1
                  city.add_reservation!(reservation)
                  exit
                end
              end
            end
            tile.reservations.clear
          end

          def hex_neighbors(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def available_hex(_entity, hex)
            pending_token[:hexes].include?(hex)
          end

          def legal_tile_rotation?(entity, hex, tile)
            old_tile = hex.tile
            all_new_exits_valid = tile.exits.all? { |edge| hex.neighbors[edge] }
            return false unless all_new_exits_valid

            return (old_tile.exits - tile.exits).empty?
          end

          def potential_tiles(entity_or_entities, hex)
            @game.tiles.select { |t| %w[13 12 206 205].include?(t.name) }.uniq(&:name)
          end
        end
      end
    end
  end
end
