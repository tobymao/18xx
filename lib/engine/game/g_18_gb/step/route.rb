# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G18GB
      module Step
        class Route < Engine::Step::Route
          def actions(entity)
            check_insolvency!(entity)
            return [] unless entity.operator?
            return [] unless @game.can_run_route?(entity)
            return [] if entity.runnable_trains.empty? && !@game.insolvent?(entity)

            ACTIONS
          end

          def check_insolvency!(entity)
            return unless entity.corporation?

            if entity.receivership? && entity.trains.empty? && @game.can_run_route?(entity) && !can_afford_depot_train?(entity)
              @game.make_insolvent(entity)
            elsif @game.insolvent?(entity) && can_afford_dept_train?(entity)
              @game.clear_insolvent(entity)
            end
          end

          def can_afford_depot_train?(entity)
            min_price = @game.depot.min_depot_price
            min_price.positive? && entity.cash >= min_price
          end
        end
      end
    end
  end
end
