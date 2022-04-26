# frozen_string_literal: true

require_relative '../../g_1822/step/dividend'

module Engine
  module Game
    module G1822PNW
      module Step
        class Dividend < Engine::Game::G1822::Step::Dividend
          def actions(entity)
            return [] if current_entity.id == 'NDEM'

            super
          end

          def skip!
            return super unless current_entity.id == 'NDEM'

            revenue = @game.routes_revenue(routes)
            process_dividend(Action::Dividend.new(
              current_entity,
              kind: revenue.positive? ? 'payout' : 'withhold',
            ))
          end

          def share_price_change(entity, revenue = 0)
            change = super
            return change unless entity.id == 'NDEM'
            return { share_direction: :left, share_times: 1 } unless revenue.positive?

            price = entity.share_price.price
            times = (revenue / price).to_i
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
