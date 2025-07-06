# frozen_string_literal: true

require_relative '../../g_1837/step/dividend'

module Engine
  module Game
    module G1824
      module Step
        class Dividend < G1837::Step::Dividend
          def dividend_types_per_entity(entity)
            return DIVIDEND_TYPES if entity.type == :minor

            DIVIDEND_TYPES - [:half]
          end

          def dividend_options(entity)
            revenue = total_revenue
            dividend_types_per_entity(entity).to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
          end
        end
      end
    end
  end
end
