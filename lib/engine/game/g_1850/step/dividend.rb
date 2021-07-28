# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G1850
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def holder_for_corporation(entity)
            entity
          end

          def share_price_change(_entity, revenue)
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            return { share_direction: :right, share_times: 1 } if revenue == @game.routes_revenue(routes)

            {}
          end
        end
      end
    end
  end
end
