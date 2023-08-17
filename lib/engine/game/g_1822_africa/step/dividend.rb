# frozen_string_literal: true

require_relative '../../g_1822/step/dividend'

module Engine
  module Game
    module G1822Africa
      module Step
        class Dividend < Engine::Game::G1822::Step::Dividend
          def share_price_change(entity, revenue = 0)
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            price = entity.share_price.price

            times = (revenue.to_f / price).floor
            times = 2 if times > 2

            if times.positive?
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
