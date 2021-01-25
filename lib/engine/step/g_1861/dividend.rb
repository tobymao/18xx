# frozen_string_literal: true

require_relative '../g_1867/dividend'

module Engine
  module Step
    module G1861
      class Dividend < G1867::Dividend
        include SkipForNational

        def payout(entity, revenue)
          return super if entity.type != :national

          { corporation: revenue, per_share: 0 }
        end

        def share_price_change(entity, revenue = 0)
          return {} if entity.type == :national

          super
        end
      end
    end
  end
end
