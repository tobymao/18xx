# frozen_string_literal: true

require_relative '../../g_1822/step/buy_sell_par_shares'

module Engine
  module Game
    module G1822MX
      module Step
        class BuySellParShares < Engine::Game::G1822::Step::BuySellParShares
          def process_buy_shares(action)
            return super if action.bundle.corporation.id != 'NDEM'

            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: false)
            track_action(action, action.bundle.corporation)
            log_pass(action.entity)
            pass!
          end
        end
      end
    end
  end
end
