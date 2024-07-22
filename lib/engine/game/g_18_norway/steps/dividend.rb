# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'

module Engine
  module Game
    module G18Norway
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue * 2 < price

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2
            times = 3 if revenue >= price * 3 && price >= 165
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def pass!
            super

            @round.steps.find { |s| s.is_a?(G18Norway::Step::IssueShares) }.dividend_step_passes
          end
        end
      end
    end
  end
end
