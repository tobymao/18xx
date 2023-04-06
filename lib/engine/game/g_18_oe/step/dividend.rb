# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18OE
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::MinorHalfPay

          def half(entity, revenue)
            withheld = half_pay_withhold_amount(entity, revenue)
            { corporation: withheld, per_share: payout_per_share(entity, revenue - withheld) }
          end

          def half_pay_withhold_amount(entity, revenue)
            (revenue / 2 / entity.total_shares) * entity.total_shares
          end

          def share_price_change(entity, revenue = 0)
            return {} if @game.minor_regional_order.include?(entity)

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue < 1

            times = 0
            times = 1 if revenue >= price
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
