# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Step
        module TrackRightsTokener
          def track_rights_available_hex(entity, hex)
            return nil unless @game.city_in_track_rights?(entity, hex)

            tokener_available_hex(entity, hex)
          end

          def check_connected(entity, city, hex)
            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            unless @game.city_in_track_rights?(entity, hex)
              raise GameError, "Cannot place token on #{hex.name} because it is outside #{entity.name}'s track rights zone"
            end

            return if @game.loading || @game.token_graph_for_entity(entity).connected_nodes(entity)[city]

            raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
          end

          def validated_token_cost(action, cost)
            return cost if !action.cost || action.cost == cost

            raise GameError, "Token costs #{@game.format_currency(cost)}, not #{@game.format_currency(action.cost)}"
          end
        end
      end
    end
  end
end
