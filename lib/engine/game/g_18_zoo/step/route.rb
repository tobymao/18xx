# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Route < Engine::Step::Route
          def process_run_routes(action)
            super

            water_gain = @round.routes.sum { |r| r.stops.sum { |s| s.tile.towns.any? ? 1 : 0 } }
            return if water_gain.zero?

            @game.bank.spend(water_gain, action.entity, check_positive: false)
            @log << "#{action.entity.name} withholds #{@game.format_currency(water_gain)} running into water tiles"
          end
        end
      end
    end
  end
end
