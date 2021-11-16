# frozen_string_literal: true

require_relative '../../g_1822/step/dividend'

module Engine
  module Game
    module G1822MX
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
        end
      end
    end
  end
end
