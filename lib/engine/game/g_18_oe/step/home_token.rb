# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18OE
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            hex = action.city.hex
            region = G18OE::Game::NATIONAL_REGION_HEXES.select { |_key, value| value.include?(hex.name.to_s) }.keys.first

            token.price = G18OE::Game::TRACK_RIGHTS_COST[region] || 0
            @game.minor_available_regions.delete_at(@game.minor_available_regions.index(region))
            @game.minor_floated_regions[action.entity.id] = region

            super
          end
        end
      end
    end
  end
end
