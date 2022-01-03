# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18NewEngland
      module Step
        class Dividend < Engine::Step::Dividend
          include Engine::Step::HalfPay
          include Engine::Step::MinorHalfPay
          DIVIDEND_TYPES = %i[payout half withhold].freeze

          def share_price_change(entity, revenue = 0)
            return {} if entity.type == :minor

            price = entity.share_price.price

            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            elsif revenue < price
              {}
            elsif revenue >= price && revenue < 2 * price
              { share_direction: :right, share_times: 1 }
            else
              { share_direction: :right, share_times: 2 }
            end
          end

          def corporation_dividends(entity, per_share)
            return 0 if entity.minor?

            # both IPO and treasury pay
            dividends_for_entity(entity, entity, per_share) +
              dividends_for_entity(entity, @game.bank, per_share)
          end
        end
      end
    end
  end
end
