# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1812
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            corporation = token.corporation
            super
            return if corporation.type == :minor

            cost = 2 * action.city.revenue.values_at(*@game.phase.tiles).compact.last
            return if cost.zero?

            corporation.spend(cost, @game.bank)
            @log << "#{corporation.name} pays #{@game.format_currency(cost)} for its home station in #{action.city.hex.full_name}"
          end
        end
      end
    end
  end
end
