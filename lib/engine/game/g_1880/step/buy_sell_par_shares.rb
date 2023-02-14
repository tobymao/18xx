# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'
require_relative 'parrer'

module Engine
  module Game
    module G1880
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          include Parrer

          def actions(entity)
            actions = super.dup
            if @game.player_debt(entity).positive?
              actions.delete('buy_shares')
              actions << 'payoff_player_debt' if entity.cash.positive?
            end

            actions
          end

          def can_sell?(entity, bundle)
            return false if @game.communism && entity == bundle.corporation.owner

            super
          end
        end
      end
    end
  end
end
