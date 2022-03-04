# frozen_string_literal: true

require_relative '../../g_1846/step/buy_sell_par_shares'

module Engine
  module Game
    module G18LosAngeles
      module Step
        class BuySellParShares < G1846::Step::BuySellParShares
          def help
            return unless @game.players.size == 3 || @game.players.size == 4

            num = @game.par_limit - @game.parred_corporations
            "#{num} more corporation#{num == 1 ? '' : 's'} may be started"
          end
        end
      end
    end
  end
end
