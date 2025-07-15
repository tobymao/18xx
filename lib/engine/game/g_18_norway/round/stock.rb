# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18Norway
      module Round
        class Stock < Engine::Round::Stock
          def corporations_to_move_price
            @game.corporations.select(&:floated?)
          end

          def sold_out?(corporation)
            corporation.share_holders.select { |s_h, _| s_h.player? || s_h == @game.nsb }.values.sum == 100
          end
        end
      end
    end
  end
end
