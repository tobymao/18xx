# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Norway
      module Step
        class Token < Engine::Step::Token
          def available_hex(entity, hex)
            return true if super

            check_available_harbour(entity, hex)
          end

          def tokener_available_hex(entity, hex)
            return true if super

            check_available_harbour(entity, hex)
          end

          def check_available_harbour(entity, hex)
            city = @game.harbor_city_id_by_harbor_id(hex.id)
            return false if city.nil?

            other_hex = @game.hex_by_id(city)
            return true if @game.graph.reachable_hexes(entity)[other_hex]

            @game.ferry_graph.reachable_hexes(entity)[other_hex]
          end

          def can_place_token?(_entity)
            true
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            hex = city.hex
            connected_city = @game.token_graph_for_entity(entity).connected_nodes(entity)[city]
            if connected_city
              place_token(entity, action.city, action.token)
            elsif @game.harbor_hex?(city.hex) && !connected_city
              city_string = city.hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              city_name = @game.harbor_city_id_by_harbor_id(hex.id) + city_string
              raise GameError, "Cannot reach city #{city_name}" unless check_available_harbour(entity, hex)

              place_token(entity, action.city, action.token, connected: false)

            else
              city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
            end
            @game.clear_graph
            pass!
          end

          def place_token(entity, city, token, connected: true, extra_action: false,
                          special_ability: nil, check_tokenable: true, spender: nil, same_hex_allowed: false)
            hex = city.hex

            check_connected(entity, city, hex) if connected
            raise GameError, 'Token already placed this turn' if !extra_action && @round.tokened

            raise GameError, 'Token is already used' if token.used

            free = !token.price.positive?
            cheater = false
            extra_slot = @game.harbor_hex?(hex)
            city.place_token(entity, token, free: free, check_tokenable: check_tokenable,
                                            cheater: cheater, extra_slot: extra_slot, spender: spender,
                                            same_hex_allowed: same_hex_allowed)
            pay_token_cost(spender || entity, token.price, city)
            price_log = " for #{@game.format_currency(token.price)}"

            hex_description = hex.location_name ? "#{hex.name} (#{hex.location_name}) " : "#{hex.name} "
            @log << "#{entity.name} places a token on #{hex_description}#{price_log}"

            @round.tokened = true
            @game.clear_token_graph_for_entity(entity)
          end
        end
      end
    end
  end
end
