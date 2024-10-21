# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1888
      module Step
        class Dividend < Engine::Step::Dividend
          def dividend_options(entity)
            revenue = @game.routes_revenue(routes)
            dividend_types.to_h do |type|
              payout = send(type, entity, revenue)
              payout[:divs_to_corporation] = corporation_dividends(entity, payout[:per_share])
              [type, payout.merge(share_price_change(entity, revenue - payout[:corporation]))]
            end
          end

          def withhold(_entity, revenue)
            { corporation: revenue, per_share: 0 }
          end

          def payout(entity, revenue)
            { corporation: 0, per_share: payout_per_share(entity, revenue) }
          end
        end
      end
    end
  end
end
