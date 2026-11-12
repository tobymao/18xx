# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative 'skip_for_national'

module Engine
  module Game
    module G18Cuba
      module Step
        class Dividend < Engine::Step::Dividend
          include SkipForNational

          def skip!
            return super unless current_entity.type == :national

            action = Action::Dividend.new(current_entity, kind: 'payout')
            action.id = @game.actions.last.id if @game.actions.last
            process_dividend(action)
          end

          def total_revenue
            return @game.fc_revenue if current_entity.type == :national

            super
          end

          def share_price_change(entity, revenue = 0)
            return super unless entity.type == :national

            { share_direction: :up, share_times: 1 }
          end

          def corporation_dividends(entity, per_share)
            return 0 if entity.type == :national

            super
          end

          def process_dividend(action)
            entity = action.entity
            revenue = total_revenue
            # Capture the routes before super, which resets @round.routes.
            routes = @round.routes
            if entity.type == :national
              log_fc_revenue_split(entity)
              @game.bank.check_cash(revenue)
            end
            super

            @game.sugar_production(entity, revenue)
            @game.collect_wagon_cubes(routes)
            # Drop any loaded-but-undelivered cubes so no binding leaks past the turn (mirrors 18Uruguay).
            entity.trains.each { |train| @game.unload_cubes(train) }
            @game.return_unshipped_cubes if entity.type == :national
          end

          private

          def log_fc_revenue_split(entity)
            @log << "#{entity.name} earns #{@game.format_currency(@game.fc_city_revenue)} from cities and "\
                    "#{@game.format_currency(@game.unshipped_cubes_revenue)} from unshipped sugar cubes"
          end
        end
      end
    end
  end
end
