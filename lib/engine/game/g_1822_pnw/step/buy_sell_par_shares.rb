# frozen_string_literal: true

require_relative '../../g_1822/step/buy_sell_par_shares'

module Engine
  module Game
    module G1822PNW
      module Step
        class BuySellParShares < Engine::Game::G1822::Step::BuySellParShares
          def process_buy_shares(action)
            return super unless action.bundle.corporation.id == 'NDEM'

            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.entity, action.bundle, swap: action.swap, allow_president_change: false)
            track_action(action, action.bundle.corporation)
            log_pass(action.entity)
            pass!
          end

          def can_sell?(entity, bundle)
            return super unless bundle.corporation.id == 'NDEM'
            return unless bundle
            return false if entity != bundle.owner

            corporation = bundle.corporation

            timing = @game.check_sale_timing(entity, corporation)

            timing &&
              !(@game.class::MUST_SELL_IN_BLOCKS && @round.players_sold[entity][corporation] == :now) &&
              can_sell_order? &&
              @game.share_pool.fit_in_bank?(bundle)
            # For NDEM, removed the "bundle.can_dump?" check
          end
        end
      end
    end
  end
end
