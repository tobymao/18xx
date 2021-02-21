# frozen_string_literal: true

require_relative '../../g_1867/step/dividend'

module Engine
  module Game
    module G1861
      module Step
        class Dividend < G1867::Step::Dividend
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
end
