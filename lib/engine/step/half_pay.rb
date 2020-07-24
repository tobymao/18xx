# frozen_string_literal: true

module Engine
  module Step
    module HalfPay
      def half(entity, revenue)
        withheld = (revenue / 2 / 10).to_i * 10
        { company: withheld, per_share: payout_per_share(entity, revenue - withheld)[0] }
      end
    end
  end
end
