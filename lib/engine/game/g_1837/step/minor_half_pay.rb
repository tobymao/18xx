# frozen_string_literal: true

module Engine
  module Game
    module G1837
      module Step
        module MinorHalfPay
          def actions(entity)
            return [] if entity.corporation? && entity.type == :minor

            super
          end

          def skip!
            return super if current_entity.corporation? && current_entity.type != :minor

            revenue = @game.routes_revenue(routes)
            kind = if revenue.zero?
                     'withhold'
                   else
                     'half'
                   end
            process_dividend(Action::Dividend.new(current_entity, kind: kind))
          end
        end
      end
    end
  end
end
