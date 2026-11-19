# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1833NE
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            corp = token.corporation
            if @game.variable_start?(corp)
              raise GameError, "#{corp.name} cannot start in that city" unless @game.variable_start_home?(corp, action.city)

              token.price = @game.variable_start_home_cost(action.city.hex)
            end
            super
          end
        end
      end
    end
  end
end
