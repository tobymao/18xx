# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Route < Engine::Step::Route
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
