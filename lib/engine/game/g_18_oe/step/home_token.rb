# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18OE
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            hex = action.city.hex
            # Use explicit zone override for cities on border hexes (listed in two zones),
            # fall back to zone lookup for all unambiguous cities.
            region = @game.class::CITY_NATIONAL_ZONE[hex.coordinates] ||
                     @game.class::NATIONAL_REGION_HEXES.find { |_, hexes| hexes.include?(hex.coordinates) }&.first

            token.price = @game.class::TRACK_RIGHTS_COST[region] || 0

            @game.minor_available_regions.delete(region)

            @game.minor_floated_regions[action.entity.id] = region

            super
          end
        end
      end
    end
  end
end
