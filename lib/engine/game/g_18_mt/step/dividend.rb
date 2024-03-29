# frozen_string_literal: true

require_relative '../../../step/dividend'

module Engine
  module Game
    module G18MT
      module Step
        class Dividend < Engine::Step::Dividend
          # TODO: Shared with 18CO
          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            return { share_direction: :right, share_times: 1 } unless revenue >= entity.share_price.price * 2

            { share_direction: %i[right up], share_times: [1, 1] }
          end
        end
      end
    end
  end
end
