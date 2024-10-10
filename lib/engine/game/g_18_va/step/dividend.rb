# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18VA
      module Step
        class Dividend < Engine::Step::Dividend
          def withhold(_entity, revenue)
            { corporation: revenue, per_share: 0 }
          end

          def payout(entity, revenue)
            { corporation: 0, per_share: payout_per_share(entity, revenue) }
          end

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero?
            return { share_direction: :right, share_times: 1 } if revenue >= price

            {}
          end

          def holder_for_corporation(_entity)
            # Incremental corps DON'T get paid from IPO shares.
            @game.share_pool
          end
        end
      end
    end
  end
end
