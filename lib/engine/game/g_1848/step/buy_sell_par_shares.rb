# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1848
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def process_buy_shares(action)
            @round.players_bought[action.entity][action.bundle.corporation] += action.bundle.percent
            @round.bought_from_ipo = true if action.bundle.owner.corporation?
            buy_shares(action.purchase_for || action.entity, action.bundle,
                       swap: action.swap, borrow_from: action.borrow_from,
                       allow_president_change: @game.pres_change_ok?(action.bundle.corporation))
            track_action(action, action.bundle.corporation)
          end

          def can_sell?(entity, bundle)
            return true if bundle.corporation == @game.boe

            super
          end

          def can_buy?(entity, bundle)
            return true if bundle.corporation == @game.boe

            super
          end
        end
      end
    end
  end
end
