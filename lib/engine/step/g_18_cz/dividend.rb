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

        def corporation_dividends(entity, per_share)
          # pays out shares in marked and in IPO
          dividends_for_entity(entity, entity,
                               per_share) + dividends_for_entity(entity, @game.share_pool, per_share)
        end
      end
    end
  end
end
