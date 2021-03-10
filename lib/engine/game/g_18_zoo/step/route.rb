# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class Route < Engine::Step::Route
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          ACTIONS = %w[run_routes].freeze

          def actions(entity)
            return ['choose_ability'] if entity.company? && can_choose_ability?(entity)

            super
          end

          def process_run_routes(action)
            super

            water_gain = @round.routes.sum { |r| r.stops.sum { |s| s.tile.towns.any? ? 1 : 0 } }
            return if water_gain.zero?

            entity = action.entity

            # Company gains nothing if it is using :TWO_BARRELS
            return if @game.two_barrels_used_this_or?(entity)

            # Company gains 1$N for each town in any route
            @game.bank.spend(water_gain, entity, check_positive: false)
            @log << "#{entity.name} withholds #{@game.format_currency(water_gain)} running into water tiles"

            # Company gains 3 if own :A_SQUEEZE
            return unless @game.a_squeeze.owner == entity

            @game.bank.spend(3, action.entity, check_positive: false)
            @log << "#{action.entity.name} earns #{@game.format_currency(3)} using 'A squeeze'"
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

          private

          def can_choose_ability?(company)
            entity = @game.current_entity
            return false if entity.player?

            # p "Route.can_choose_ability?(#{company.name})" # TODO: use for debug
            return true if can_choose_ability_on_any_step(entity, company)
            return true if company == @game.two_barrels && can_choose_two_barrels?(entity)
            return true if company == @game.wings && can_choose_wings?(entity)
            return true if company == @game.a_spoonful_of_sugar && can_choose_sugar?(entity)

            false
          end
        end
      end
    end
  end
end
