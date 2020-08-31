# frozen_string_literal: true

module Engine
  module Step
    module HalfPay
      def half(entity, revenue)
        withheld = (revenue / 2 / entity.total_shares).to_i * entity.total_shares
        { corporation: withheld, per_share: payout_per_share(entity, revenue - withheld) }
      end
    end
  end
end
