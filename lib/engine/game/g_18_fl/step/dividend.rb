# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18FL
      module Step
        class Dividend < Engine::Step::Dividend
          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue.zero?

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2
            if times.positive? && (entity.type != :medium || !entity.share_price.types.include?(:max_price))
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end
        end
      end
    end
  end
end
