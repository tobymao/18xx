# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18CZ
      class Dividend < Dividend
        def payout_per_share(entity, revenue)
          (revenue / entity.total_shares).to_i
        end

        def share_price_change(entity, revenue = 0)
          return { share_direction: :left, share_times: 2 } unless revenue.positive?

          times = 2
          times = 4 if entity.type == :large
          { share_direction: :right, share_times: times }
        end

        def corporation_dividends(_entity, _per_share)
          0
        end
      end
    end
  end
end
