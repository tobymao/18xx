# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1870
      class Stock < Stock
        def sold_out?(corporation)
          return super if @game.turn < 7 || @game.turn == 7 && corporation.id == 'GMO'

          corporation.player_share_holders.values.sum + corporation.reserved_shares.sum(&:percent) == 100
        end
      end
    end
  end
end
