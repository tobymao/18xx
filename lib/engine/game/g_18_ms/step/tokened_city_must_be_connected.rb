# frozen_string_literal: true

module Engine
  module Game
    module G18MS
      module TokenedCityMustBeConnected
        def process_place_token(action)
          entity = action.entity
          entity = entity.owner if entity.company?
          city = action.city
          hex = city.hex
          if !@game.loading && !@game.graph.connected_nodes(entity)[city]
            city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
          end

          super
        end
      end
    end
  end
end
