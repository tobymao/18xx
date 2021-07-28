# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1850
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            return super if @game.turn < 7 || @game.turn == 7 && corporation.id == 'UP'

            corporation.player_share_holders.values.sum + corporation.reserved_shares.sum(&:percent) == 100
          end
        end
      end
    end
  end
end
