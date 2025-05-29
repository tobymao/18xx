# frozen_string_literal: true

require_relative '../../../step/dividend'
# require_relative '../../operating_info'
# require_relative '../../action/dividend'

module Engine
  module Game
    module G18India
      module Step
        class Dividend < Engine::Step::Dividend
          def guaranty_pay(entity)
            return 0 unless entity.guaranty_warrant?

            market_value = entity.share_price.price
            market_value.div(20) # pay 5% of market value rounded down
          end

          # guaranty corps pay out 5%
          def withhold(entity, revenue)
            { corporation: revenue, per_share: guaranty_pay(entity) }
          end

          # total shares should always be 10 (when railroad bonds convert => payout could exceed 100%)
          def payout_per_share(_entity, revenue)
            revenue / 10.to_f
          end

          # Should "Per Share" or "payout" be used as parameter for this method?
          def payout_shares(entity, revenue)
            # if revenue == 0 then use guaranty pay
            revenue = guaranty_pay(entity) * 10 if revenue.zero?
            super
          end

          # share movement chart
          def share_price_change(entity, revenue)
            curr_price = entity.share_price.price

            if revenue >= 4 * curr_price
              { share_direction: :right, share_times: 4 }
            elsif revenue >= 3 * curr_price
              { share_direction: :right, share_times: 3 }
            elsif revenue >= 2 * curr_price
              { share_direction: :right, share_times: 2 }
            elsif revenue > curr_price / 2
              { share_direction: :right, share_times: 1 }
            elsif revenue.positive? || guaranty_pay(entity).positive?
              {}
            else
              { share_direction: :left, share_times: 1 }
            end
          end
        end
      end
    end
  end
end
