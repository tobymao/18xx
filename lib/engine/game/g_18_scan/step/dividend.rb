# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18Scan
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::MinorHalfPay

          def process_dividend(action)
            # super clears routes so revenue must be calculated beforehand
            revenue = @game.routes_revenue(routes)
            entity = action.entity

            super

            return if (entity.corporation? && entity.type != :minor) ||
              revenue.positive?

            @game.bank.spend(@game.class::MINOR_SUBSIDY, entity)

            @log << "#{entity.owner.name} receives subsidy of #{@game.format_currency(@game.class::MINOR_SUBSIDY)}"
          end

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?

            price = entity.share_price.price

            return { share_direction: :left, share_times: 1 } if revenue.zero?

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2

            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end
        end
      end
    end
  end
end
