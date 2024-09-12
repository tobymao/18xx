# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Norway
      module Step
        class Token < Engine::Step::Token
          def available_hex(entity, hex)
            return true if super

            harbor_available?(entity, hex)
          end

          def tokener_available_hex(entity, hex)
            return true if super

            harbor_available?(entity, hex)
          end

          def harbor_available?(entity, hex)
            other_hex = @game.hex_by_id(@game.harbor_city_coordinates(hex.id))
            @game.graph.reachable_hexes(entity)[other_hex] || @game.ferry_graph.reachable_hexes(entity)[other_hex]
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
            elsif @game.harbor_hex?(city.hex)
              city_string = city.hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              city_name = @game.harbor_city_coordinates(hex.id) + city_string
              raise GameError, "Cannot reach city #{city_name}" unless harbor_available?(entity, hex)

              place_token(entity, action.city, action.token, connected: false, extra_slot: true)

            else
              city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
            end
            @game.clear_graph
            pass!
          end
        end
      end
    end
  end
end
