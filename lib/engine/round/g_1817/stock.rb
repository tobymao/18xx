# frozen_string_literal: true

require_relative '../stock'

module Engine
  module Round
    module G1817
      class Stock < Stock
        def finish_round
          super
          @game.corporations.select(&:floated?).each do |corp|
            if tokens_needed?(corp)
              @log << "#{corp.name} did not purchase tokens and liquidates"
              @game.liquidate!(corp)
            end
          end
        end

        def tokens_needed?(corporation)
          !corporation.operated? && @game.tokens_needed(corporation).positive?
        end

        def sold_out?(corporation)
          corporation.total_shares > 2 && corporation.player_share_holders.values.sum >= 100
        end
      end
    end
  end
end
