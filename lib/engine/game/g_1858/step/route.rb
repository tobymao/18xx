# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1858
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            return [] unless entity.corporation?
            return [] if entity.runnable_trains.empty? && entity.companies.empty?

            ACTIONS
          end

          def process_run_routes(action)
            super
            log_company_revenue(action.entity)
          end

          def log_company_revenue(corporation)
            corporation.companies.each do |company|
              revenue_str = @game.format_revenue_currency(company.revenue)
              @log << "#{corporation.name} receives #{revenue_str} revenue " \
                      "from private railway #{company.name}"
            end
          end

          def log_skip(entity)
            super unless entity.minor?
          end
        end
      end
    end
  end
end
