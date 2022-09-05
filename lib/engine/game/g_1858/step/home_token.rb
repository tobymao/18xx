# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1858
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            # Home token cost for public companies is twice the city's revenue.
            city = action.city
            color = city.tile.color
            token.price = 2 * city.revenue[color] unless color == :white
            super
          end
        end
      end
    end
  end
end
