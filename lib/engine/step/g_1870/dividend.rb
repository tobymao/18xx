# frozen_string_literal: true

require_relative '../dividend'
require_relative '../half_pay'

module Engine
  module Step
    module G1870
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay

        def share_price_change(_entity, revenue)
          return { share_direction: :left, share_times: 1 } if revenue.zero?

          return { share_direction: :right, share_times: 1 } if revenue == @game.routes_revenue(routes)

          {}
        end

        def holder_for_corporation(entity)
          entity
        end
      end
    end
  end
end
