# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18Texas
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price

            if revenue.zero?
              { share_direction: :left, share_times: 1 }
            elsif revenue < price
              {}
            elsif revenue >= price
              { share_direction: :right, share_times: 1 }
            end
          end

          def pass!
            super
          end
        end
      end
    end
  end
end
