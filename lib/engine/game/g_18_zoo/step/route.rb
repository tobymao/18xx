# frozen_string_literal: true

require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class Route < Engine::Step::Route
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          def process_run_routes(action)
            super

            water_gain = @round.routes.sum { |r| r.stops.sum { |s| s.tile.towns.any? ? 1 : 0 } }
            return if water_gain.zero?

            @game.bank.spend(water_gain, action.entity, check_positive: false)
            @log << "#{action.entity.name} withholds #{@game.format_currency(water_gain)} running into water tiles"
          end

          def chart(entity)
            coordinates = entity.share_price.coordinates
            threshold = @game.class::STOCKMARKET_THRESHOLD[coordinates[0]][coordinates[1]]
            [
              ['Revenue', 'Price Change'],
              ['withhold', '1 ←'],
              ["< #{threshold}", 'none'],
              ["≥ #{threshold}", '1 →'],
            ]
          end
        end
      end
    end
  end
end
