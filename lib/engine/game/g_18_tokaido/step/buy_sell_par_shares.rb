# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Tokaido
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def buyable_bank_owned_companies(entity)
            return [] if !entity.player? || bought?

            @game.buyable_bank_owned_companies.select { |c| can_buy_company?(entity, c) }
          end

          def process_buy_company(action)
            super

            @round.last_to_act = action.entity.player
          end
        end
      end
    end
  end
end
