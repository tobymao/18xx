# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Norway
      module Step
        class Token < Engine::Step::Token
          def available_hex(entity, hex)
            return true if super(entity, hex)

            return true if check_available_harbour(entity, hex)

            false
          end

          def check_available_harbour(entity, hex)
            city = @game.harbor_city_coordinates(hex.id)
            return false if city.nil?

            other_hex = @game.hex_by_id(city)

            return false unless @game.ferry_graph.reachable_hexes(entity)[other_hex]

            true
          end

          def can_place_token?(_entity)
            true
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            connected_city = @game.loading || @game.token_graph_for_entity(entity).connected_nodes(entity)[city]
            if connected_city
              place_token(entity, action.city, action.token)
            elsif @game.harbor_hex?(city.hex) && !connected_city
              reachable_hexes = @game.ferry_graph.reachable_hexes(entity)[city.hex]

              @game.abilities(entity, :token) do |ability|
                place_token(entity, action.city, action.token, connected: false, special_ability: ability)
              end
            else
              raise GameError, "Cannot place token on #{city.hex.name} city is not connected"
            end
            @game.clear_graph
            pass!
          end
        end
      end
    end
  end
end
