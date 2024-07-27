# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Route < Engine::Step::Route
          def help
            return super unless current_entity.receivership?

            "#{current_entity.type == :minor ? 'Minor ' : ''}" \
              "#{current_entity.name} is on autopilot as it does not have a " \
              'president. It may not place any track or tokens or buy a ' \
              'train. It will run its trains and pay out dividends. Please ' \
              'select the best route you can see.'
          end

          def log_extra_revenue(entity, extra_revenue)
            return unless extra_revenue&.nonzero?

            revenue_str = @game.format_revenue_currency(extra_revenue)
            @log << "#{entity.name} receives #{revenue_str} revenue from forts"
          end
        end
      end
    end
  end
end
