# frozen_string_literal: true

module Engine
  module Step
    module HalfPay
      def half(entity, revenue)
        withheld = half_pay_withhold_amount(entity, revenue)
        { corporation: withheld, per_share: payout_per_share(entity, revenue - withheld) }
      end

      def half_pay_withhold_amount(entity, revenue)
        (revenue / 2 / entity.total_shares).to_i * entity.total_shares
      end
    end
  end
end
