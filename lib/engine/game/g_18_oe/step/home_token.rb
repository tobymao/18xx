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
            region = G18OE::Game::CITY_NATIONAL_ZONE[hex.name.to_s] ||
                     G18OE::Game::NATIONAL_REGION_HEXES
                       .select { |_key, value| value.include?(hex.name.to_s) }
                       .keys.first

            token.price = G18OE::Game::TRACK_RIGHTS_COST[region] || 0

            idx = @game.minor_available_regions.index(region)
            @game.minor_available_regions.delete_at(idx) if idx

            @game.minor_floated_regions[action.entity.id] = region

            super
          end
        end
      end
    end
  end
end
