# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1873
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] if entity.minor? || @game.public_mine?(entity) || entity == @game.mhe
            return [] if entity.company?

            super
          end

          def skip!
            return super if !@game.any_mine?(current_entity) && current_entity != @game.mhe

            if @game.any_mine?(current_entity)
              @game.update_mine_revenue(@round, current_entity) if @round.routes.empty?
            end

            pass!
          end

          def process_run_routes(action)
            super

            entity = action.entity
            maintenance = @game.maintenance_costs(entity)
            @round.maintenance = maintenance
            @log << "#{entity.name} owes #{@game.format_currency(maintenance)} for maintenance" if maintenance.positive?
          end

          def round_state
            {
              routes: [],
              maintenance: 0,
            }
          end
        end
      end
    end
  end
end
