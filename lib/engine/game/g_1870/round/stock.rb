# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G1870
      module Round
        class Stock < Engine::Round::Stock
          def sold_out?(corporation)
            corporation.player_share_holders.values.sum + corporation.reserved_shares.sum(&:percent) == 100
          end
        end
      end
    end
  end
end
