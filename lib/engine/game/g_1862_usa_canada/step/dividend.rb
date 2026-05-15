# frozen_string_literal: true

module Engine
  module Game
    module G1862UsaCanada
      module Step
        class Dividend < Engine::Step::Dividend
          def process_dividend(action)
            paying = action.kind.to_sym == :payout
            @game.activate_new_bonuses!(action.entity, routes)
            @game.check_golden_spike!(action.entity, routes)
            super
            @game.check_private_close_on_dividend!(action.entity) if paying
          end
        end
      end
    end
  end
end
