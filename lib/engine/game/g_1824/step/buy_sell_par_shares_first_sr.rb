# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G1824
      module Step
        class BuySellParSharesFirstSr < Engine::Step::BuySellParShares
          def can_buy_company?(_player, _company)
            !bought?
          end

          def can_buy?(_entity, bundle)
            super && @game.buyable?(bundle.corporation)
          end

          def can_sell?(_entity, _bundle)
            false
          end

          def can_gain?(_entity, bundle, exchange: false)
            return false if exchange

            super && @game.buyable?(bundle.corporation)
          end

          def can_exchange?(_entity)
            false
          end

          def visible_corporations
            # None if Cislethania variant
            return [] if @game.option_cisleithania

            # Rule VI.3 bullet 4 - only BH available of the Regional Railways
            [@game.corporation_by_id('BH')]
          end
        end
      end
    end
  end
end
