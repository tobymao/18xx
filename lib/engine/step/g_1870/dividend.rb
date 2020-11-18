# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G1870
      class Dividend < Dividend
        DIVIDEND_TYPES = %i[payout half withhold].freeze
        include HalfPay

        def holder_for_corporation(entity)
          entity
        end

        def share_price_change(_entity, revenue)
          if revenue.positive?
            if revenue == @game.routes_revenue(routes)
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          else
            { share_direction: :left, share_times: 1 }
          end
        end
      end
    end
  end
end
