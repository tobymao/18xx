# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G1841
      module Step
        class Dividend < Engine::Step::Dividend
          def share_price_change(entity, revenue = 0)
            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            if revenue > price
              { share_direction: :right, share_times: 1 }
            else
              {}
            end
          end
        end
      end
    end
  end
end
