# frozen_string_literal: true

require_relative '../../../step/exchange'

module Engine
  module Game
    module G18MO
      module Step
        class Exchange < Engine::Step::Exchange
          def process_buy_shares(action)
            super

            @game.exchanged_share = action.bundle.shares[0]
          end
        end
      end
    end
  end
end
