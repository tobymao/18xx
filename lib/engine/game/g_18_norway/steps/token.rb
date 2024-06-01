# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18Norway
      module Step
        class Token < Engine::Step::Token
          def available_hex(entity, hex)
            return true if super(entity, hex)
            return true if @game.ferry_graph.reachable_hexes(entity)[hex]

            false
          end

          def can_place_token?(_entity)
            true
          end

          def process_place_token(action)
            entity = action.entity
            city = action.city
            connected_city = @game.loading || @game.token_graph_for_entity(entity).connected_nodes(entity)[city]
            place_token(entity, action.city, action.token) if connected_city

            unless connected_city
              @game.abilities(entity, :token) do |ability|
                place_token(entity, action.city, action.token, connected: false, special_ability: ability)
              end
            end
            @game.clear_graph
            pass!
          end

          def check_connected(entity, city, hex)
            return if @game.loading || @game.token_graph_for_entity(entity).connected_nodes(entity)[city]
            return if @game.loading || @game.ferry_graph.connected_nodes(entity)[city]

            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
          end
        end
      end
    end
  end
end
