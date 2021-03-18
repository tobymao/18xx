# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18FL
      module Step
        class Token < Engine::Step::Token
          ACTIONS = %w[place_token hex_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity)

            ACTIONS
          end

          def can_place_token?(entity)
            !@game.round.laid_token[entity] && (
              !@game.token_company.closed? ||
              (current_entity == entity &&
                !(tokens = available_tokens(entity)).empty? &&
                min_token_price(tokens) <= buying_power(entity))
            )
          end

          def process_place_token(action)
            raise GameError, "#{action.entity.name} cannot lay token now" if @game.round.laid_token[action.entity]

            raise GameError, "#{action.entity.name} cannot afford "\
                "#{@game.format_currency(action.cost)} to lay token in "\
                "#{action.city.hex.tile.location_name}" if action.cost > action.entity.cash

            action.token.price = action.cost if action.cost
            super
            @game.round.laid_token[action.entity] = true
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(entity)[hex]
          end

          def process_hex_token(action)
            entity = action.entity
            hex = action.hex
            token = action.token

            raise GameError, "#{hex.id} is not a town" if hex.tile.towns.empty?
            raise GameError, "#{entity.name} already has a hotel in #{hex.tile.location_name}" if tokened(hex, entity)

            cost = action.cost # We are using token_cost_override
            raise GameError, "#{entity.name} cannot afford "\
                  "#{@game.format_currency(cost)} cost to lay hotel" if cost > entity.cash

            @game.log << "#{entity.name} places a hotel on #{hex.name} for #{@game.format_currency(cost)}"
            entity.spend(cost, @game.bank)

            entity.tokens.delete(token)
            hex.tile.icons << Part::Icon.new("../logos/18_fl/#{entity.id}")
            pass!
          end

          def token_cost_override(entity, city_hex, _slot, token, _tokener)
            hex = city_hex.respond_to?(:city?) ? city_hex.hex : city_hex
            token.price * distance_to_station(entity, hex)
          end

          def tokened(hex, entity)
            hex.tile.icons.any? { |i| i.name == entity.id }
          end

          # How far is the start_hex from one of the corporation's stations?
          # This is by track, not as the crow flies.
          # start is either a city or hex (plain track or town)
          def distance_to_station(corporation, start)
            goal_hexes = corporation.tokens.select(&:city).map { |t| [t.city.hex, t.city] }
            distance = 0
            visited_hexes = []
            start_hexes = if start.is_a?(Engine::Part::City)
                            [[start.hex, start]]
                          else # Hex
                            [[start, start.tile.cities.first]]
                          end
            until start_hexes.empty?
              return distance unless (start_hexes & goal_hexes).empty?

              distance += 1
              hexes_to_visit = start_hexes
              start_hexes = []
              hexes_to_visit.each do |hex_c|
                visited_hexes << hex_c
                valid_neighbors(hex_c).each do |e, neighbor|
                  # Ignore this neighbor if they don't connect to each other
                  next unless hex_c.first.tile.exits.include?(e) && neighbor.tile.exits.include?((e + 3) % 6)

                  neighbor_cities((e + 3) % 6, neighbor).each do |city|
                    neighbor_hc = [neighbor, city]
                    # Don't revisit hexes
                    return distance if goal_hexes.include?(neighbor_hc)
                    next if visited_hexes.include?(neighbor_hc) || hexes_to_visit.include?(neighbor_hc)

                    start_hexes << neighbor_hc unless neighbor_hc[1]&.blocks?(corporation)
                  end
                end
              end
            end
            # Didn't return early, couldn't find a station connected.
            # This shouldn't happen? If this is called the spot is tokenable
            # and if the spot is tokenable it is visible from an existing station?
            raise GameError, 'Distance is uncalculable'
          end

          # Which of the hex-city neighbors are reachable directly?
          def valid_neighbors(hex_c)
            return hex_c.first.neighbors unless hex_c.first.tile.cities.count > 1

            valid_edges = hex_c.last.exits
            hex_c.first.neighbors.select { |edge, _| valid_edges.include?(edge) }
          end

          # What cities in this hex can we reach from this incoming edge?
          def neighbor_cities(incoming_edge, hex)
            return [nil] if hex.tile.cities.empty?

            reachable_cities = hex.tile.cities.select { |c| c.exits.include?(incoming_edge) }
            reachable_cities.empty? ? [nil] : reachable_cities
          end
        end
      end
    end
  end
end
