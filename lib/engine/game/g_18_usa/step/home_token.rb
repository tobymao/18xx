# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18USA
      module Step
        class HomeToken < Engine::Step::HomeToken
          def round_state
            super.merge(
              {
                minimum_city_subsidy: 0,
              }
            )
          end

          def process_place_token(action)
            corporation = token.corporation
            super
            @game.add_subsidy(corporation, action.city.hex)
            @round.minimum_city_subsidy = 0
          end

          def available_hex(_entity, hex)
            return false unless super
            return true if @round.minimum_city_subsidy.zero?

            city_subsidy = (subsidy = @game.subsidies_by_hex[hex.coordinates]) ? subsidy[:value] : 0
            city_subsidy >= @round.minimum_city_subsidy
          end
        end
      end
    end
  end
end
