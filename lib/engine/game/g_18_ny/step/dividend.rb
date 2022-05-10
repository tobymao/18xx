# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18NY
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay
          include Engine::Step::MinorHalfPay

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            revenue *= 2 if entity.type == :minor
            return { share_direction: :right, share_times: 1 } if revenue >= price
            return { share_direction: :left, share_times: 1 } if (revenue * 2) < price

            {}
          end
        end
      end
    end
  end
end
