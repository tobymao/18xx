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
            return pass! if current_entity == @game.mhe

            maintenance = @game.maintenance_costs(current_entity)
            @round.maintenance = maintenance
            if maintenance.positive? && @game.railway?(current_entity)
              @log << "#{current_entity.name} owes #{@game.format_currency(maintenance)} for maintenance"
            end

            @game.update_tokens(current_entity, [])
            return super if !@game.any_mine?(current_entity) && current_entity != @game.qlb

            if current_entity == @game.qlb
              @log << "QLB only runs local train for #{@game.format_currency(@game.qlb_bonus)}"
            end

            if @game.any_mine?(current_entity)
              @game.update_mine_revenue(@round, current_entity) if @round.routes.empty?
              @round.clear_cache!
            end

            pass!
          end

          def help
            return super unless current_entity.receivership?

            "#{current_entity.name} is in receivership (it went insolvent). Most of its "\
              'actions are automated, but it must have a player manually run its trains. '\
              'Please see "Harzbahn 1873" Rules of Play Section 6.2 and enter the '\
              "mandated routes for #{current_entity.name}."
          end

          def process_run_routes(action)
            super

            entity = action.entity
            routes = action.routes

            @log << "QLB runs local train for #{@game.format_currency(@game.qlb_bonus)}" if entity == @game.qlb

            routes.each do |r|
              @game.use_pool_diesel(r.train, entity) if @game.diesel?(r.train)
            end
            @game.free_pool_diesels(entity)

            maintenance = @game.maintenance_costs(entity)
            @round.maintenance = maintenance
            @log << "#{entity.name} owes #{@game.format_currency(maintenance)} for maintenance" if maintenance.positive?

            @game.update_tokens(entity, action.routes)
          end

          def train_name(_entity, train)
            @game.train_name(train)
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
