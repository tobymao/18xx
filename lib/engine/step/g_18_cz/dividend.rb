# frozen_string_literal: true

require_relative '../dividend'

module Engine
  module Step
    module G18CZ
      class Dividend < Dividend
        def share_price_change(entity, revenue = 0)
          return { share_direction: :left, share_times: 2 } unless revenue.positive?

          times = 2
          times = 4 if entity.type == :large
          { share_direction: :right, share_times: times }
        end
      end
    end
  end
end
