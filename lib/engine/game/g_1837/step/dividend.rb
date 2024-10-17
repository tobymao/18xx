# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G1837
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay
          include Engine::Step::MinorHalfPay

          def share_price_change(_entity, revenue)
            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            elsif revenue == total_revenue
              { share_direction: :right, share_times: 1 }
            else
              { share_direction: :diagonally_down_right, share_times: 1 }
            end
          end
        end
      end
    end
  end
end
