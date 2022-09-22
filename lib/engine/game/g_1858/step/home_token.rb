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

            # FIXME
            # There is a bug that is corrupting games, it occurs here when
            # undoing moves, the city passed as part of the action object did
            # not have an associated hex. Maybe a bug at a higher level?
            # Having a company start with a token in Lisboa is a reliable way
            # of triggering this bug.
            super
          end
        end
      end
    end
  end
end
